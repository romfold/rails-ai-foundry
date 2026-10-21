# frozen_string_literal: true

require 'test_helper'

class DeliveryTest < ActionDispatch::IntegrationTest
  test 'authenticated tenant owns the stream and stale writes return conflict' do
    account = SecureRandom.hex(8)
    path = "/accounts/#{account}"
    get path
    assert_response :unauthorized
    post path, params: { cents: 100, expected_version: -1, tenant: 'b' },
               headers: { 'Authorization' => 'Bearer demo-a' }, as: :json
    assert_response :created
    assert_equal 100, response.parsed_body.fetch('balance')
    get path, headers: { 'Authorization' => 'Bearer demo-b' }
    assert_equal 0, response.parsed_body.fetch('balance')
    post path, params: { cents: -10, expected_version: -1 },
               headers: { 'Authorization' => 'Bearer demo-a' }, as: :json
    assert_response :conflict
  end
end
