# frozen_string_literal: true

require 'test_helper'

class DeliveryTest < ActionDispatch::IntegrationTest
  test 'HTTP identity overrides supplied actor and tenant parameters' do
    actor = Assistance::User.create!(tenant: 'a', token: SecureRandom.hex)
    ticket = Assistance::Ticket.create!(tenant: 'a', subject: 'Delivery')
    post '/answers', params: { ticket_id: ticket.id, question: 'Status?' }, as: :json
    assert_response :unauthorized
    post '/answers', params: { ticket_id: ticket.id, question: 'Status?', tenant: 'b', actor_id: 0 },
                     headers: { 'Authorization' => "Bearer #{actor.token}" }, as: :json
    assert_response :success
    assert_equal ticket.id, response.parsed_body.fetch('ticket_id')
    assert_equal 'open', response.parsed_body.fetch('status')
  end
end
