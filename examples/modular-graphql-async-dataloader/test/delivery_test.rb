# frozen_string_literal: true

require 'test_helper'

class DeliveryTest < ActionDispatch::IntegrationTest
  test 'HTTP GraphQL derives tenant and read role from trusted delivery' do
    post '/graphql', params: { query: '{ people(ids: []) { name } }' }, as: :json
    assert_response :unauthorized
    post '/graphql', params: { query: '{ people(ids: []) { name } }', tenant: 'b', role: 'writing' },
                     headers: { 'Authorization' => 'Bearer demo-a' }, as: :json
    assert_response :success
    assert_equal [], response.parsed_body.dig('data', 'people')
  end
end
