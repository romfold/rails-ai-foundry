# frozen_string_literal: true

require_relative 'test_helper'

class ReviewedAcceptanceTest < ActionDispatch::IntegrationTest
  setup do
    @reader = SupportDesk::User.create!(tenant: 'north', token: SecureRandom.hex)
    @editor = SupportDesk::User.create!(tenant: 'north', token: SecureRandom.hex, can_close: true)
    @outsider = SupportDesk::User.create!(tenant: 'south', token: SecureRandom.hex, can_close: true)
    @ticket = SupportDesk::Ticket.create!(tenant: 'north', subject: 'Replace missing item')
  end

  def submit(actor = @reader)
    post '/resolutions', params: { ticket_id: @ticket.id, question: 'Resolve this ticket',
                                   idempotency_key: 'request-001', actor_id: @outsider.id, tenant: 'south' },
                         headers: headers(actor), as: :json
    assert_response :accepted
    SupportDesk::ResolutionRequest.find(response.parsed_body.fetch('id'))
  end

  def headers(actor)
    { 'Authorization' => "Bearer #{actor.token}" }
  end

  def approve(work, actor = @editor)
    post "/resolutions/#{work.id}/approve",
         params: { proposal_digest: work.proposal_digest,
                   ticket_revision: work.source_revision },
         headers: headers(actor), as: :json
  end

  test 'HTTP identity and approval bind one durable local result' do
    work = submit
    assert_equal @reader.id, work.requester_id
    SupportDesk::GenerateResolution.call(work.id)
    approve(work.reload, @reader)
    assert_response :forbidden
    SupportDesk::ExecuteResolution.call(work.id)
    assert_equal 'open', @ticket.reload.status
    approve(work)
    assert_response :accepted
    assert_equal 'open', @ticket.reload.status
    3.times { SupportDesk::ExecuteResolution.call(work.id) }
    assert_equal 'completed', work.reload.state
    assert_equal work.proposal, @ticket.reload.approved_resolution
    assert_equal 1, @ticket.lock_version
    assert_equal 1, SupportDesk::ResolutionAudit.where(resolution_request_id: work.id, event: 'completed').count
  end

  test 'foreign resources and injected identity cannot authorize decisions' do
    work = submit
    get "/resolutions/#{work.id}", headers: headers(@outsider), as: :json
    assert_response :not_found
    SupportDesk::GenerateResolution.call(work.id)
    approve(work.reload, @outsider)
    assert_response :not_found
    @reader.update!(active: false)
    approve(work)
    assert_response :conflict
    SupportDesk::ExecuteResolution.call(work.id)
    assert_equal 'open', @ticket.reload.status
  end

  test 'self approval works only for a currently authorized editor and source revision' do
    work = submit(@editor)
    SupportDesk::GenerateResolution.call(work.id)
    approve(work.reload, @editor)
    assert_response :accepted
    @ticket.update!(subject: 'Changed after approval')
    SupportDesk::ExecuteResolution.call(work.id)
    assert_equal 'stale', work.reload.state
    assert_equal 'open', @ticket.reload.status
  end

  test 'request identity conflicts and cancellation preserve decisions' do
    work = submit
    assert_equal work.id, submit.id
    post '/resolutions', params: { ticket_id: @ticket.id, question: 'Different', idempotency_key: 'request-001' },
                         headers: headers(@reader), as: :json
    assert_response :conflict
    post "/resolutions/#{work.id}/cancel", headers: headers(@reader), as: :json
    assert_response :accepted
    SupportDesk::GenerateResolution.call(work.id)
    SupportDesk::ExecuteResolution.call(work.id)
    assert_equal 'cancelled', work.reload.state
    assert_equal 'open', @ticket.reload.status
  end

  def provider(text, &during_call)
    Object.new.tap do |object|
      object.define_singleton_method(:provenance) { 'controlled-offline' }
      object.define_singleton_method(:call) do |**|
        during_call&.call
        text
      end
    end
  end

  test 'expired ownership cannot persist old provider output' do
    work = submit
    delayed = provider('Obsolete provider result') { work.reload.update!(lease_expires_at: 1.second.ago) }
    SupportDesk::GenerateResolution.call(work.id, provider: delayed)
    assert_nil work.reload.proposal
    SupportDesk::GenerateResolution.call(work.id, provider: provider('Current provider result'))
    assert_equal 'Current provider result', work.reload.proposal
    assert_equal 'awaiting_review', work.state
    assert_equal 2, work.attempt_count
  end

  test 'revoked approver and modified digest cannot execute' do
    work = submit
    SupportDesk::GenerateResolution.call(work.id)
    work.reload
    post "/resolutions/#{work.id}/approve",
         params: { proposal_digest: 'tampered', ticket_revision: work.source_revision },
         headers: headers(@editor), as: :json
    assert_response :conflict
    approve(work)
    assert_response :accepted
    @editor.update!(active: false)
    SupportDesk::ExecuteResolution.call(work.id)
    assert_equal 'stale', work.reload.state
    assert_equal 'open', @ticket.reload.status
  end
end
