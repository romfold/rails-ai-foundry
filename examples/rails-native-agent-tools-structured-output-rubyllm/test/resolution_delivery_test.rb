# frozen_string_literal: true

require_relative 'test_helper'

class ResolutionDeliveryTest < ActionDispatch::IntegrationTest
  setup do
    @reader = Assistance::User.create!(tenant: 'a', token: SecureRandom.hex)
    @editor = Assistance::User.create!(tenant: 'a', token: SecureRandom.hex, can_close: true)
    @ticket = Assistance::Ticket.create!(tenant: 'a', subject: 'Delivery')
  end

  def headers(actor = @reader)
    { 'Authorization' => "Bearer #{actor.token}" }
  end

  test 'HTTP request review execution and status preserve identity authority' do
    post '/resolutions', params: { ticket_id: @ticket.id, question: 'Resolve', idempotency_key: 'http',
                                   requester_id: @editor.id, state: 'approved' }, headers: headers, as: :json
    assert_response :accepted
    location = response.headers.fetch('Location')
    work = Assistance::ResolutionRequest.find(response.parsed_body.fetch('id'))
    assert_equal @reader.id, work.requester_id
    assert_equal 'queued', work.state
    Assistance::GenerateResolution.call(work.id)
    work.reload
    post "#{location}/approve", params: { proposal_digest: work.proposal_digest,
                                          ticket_revision: work.source_revision },
                                headers: headers, as: :json
    assert_response :forbidden
    post "#{location}/approve", params: { proposal_digest: work.proposal_digest,
                                          ticket_revision: work.source_revision },
                                headers: headers(@editor), as: :json
    assert_response :accepted
    assert_equal 'approved', response.parsed_body.fetch('state')
    Assistance::ExecuteResolution.call(work.id)
    get location, headers: headers, as: :json
    assert_response :success
    assert_equal 'completed', response.parsed_body.fetch('state')
    post "#{location}/cancel", headers: headers, as: :json
    assert_response :conflict
  end

  test 'foreign tenant is concealed and revoked identities cannot inject an actor' do
    work = Assistance::RequestResolution.call(actor_id: @reader.id, ticket_id: @ticket.id, question: 'Resolve',
                                              key: 'a')
    foreign = Assistance::User.create!(tenant: 'b', token: SecureRandom.hex)
    get "/resolutions/#{work.id}", headers: headers(foreign), as: :json
    assert_response :not_found
    @reader.update!(active: false)
    post "/resolutions/#{work.id}/approve", params: { actor_id: @editor.id }, headers: headers, as: :json
    assert_response :unauthorized
  end

  test 'browser actions require CSRF even when caller supplies identity parameters' do
    previous = ActionController::Base.allow_forgery_protection
    ActionController::Base.allow_forgery_protection = true
    assert_raises(ActionController::InvalidAuthenticityToken) do
      post '/demo/login', params: { identity: 'editor' }
    end
  ensure
    ActionController::Base.allow_forgery_protection = previous
  end
end
