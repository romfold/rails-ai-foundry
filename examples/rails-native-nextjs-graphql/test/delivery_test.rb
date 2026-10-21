# frozen_string_literal: true

require 'test_helper'

class DeliveryTest < ActionDispatch::IntegrationTest
  test 'Rails GraphQL owns authorization and batches the frontend read shape' do
    manager = Directory::Person.create!(tenant: 'a', name: 'Manager')
    person = Directory::Person.create!(tenant: 'a', name: 'Alice', manager_id: manager.id)
    secret = Directory::Person.create!(tenant: 'b', name: 'Private')
    body = { query: 'query($ids:[ID!]!){ people(ids:$ids){ name manager { name } } }',
             variables: { ids: [person.id, secret.id] } }
    post '/graphql', params: body, as: :json
    assert_response :unauthorized
    post '/graphql', params: body, headers: { 'Authorization' => 'Bearer demo-a' }, as: :json
    assert_response :success
    assert_equal [{ 'name' => 'Alice', 'manager' => { 'name' => 'Manager' } }, nil],
                 response.parsed_body.dig('data', 'people')
    post '/graphql', params: body, headers: { 'Authorization' => 'Bearer demo-b' }, as: :json
    assert_equal [nil, { 'name' => 'Private', 'manager' => nil }], response.parsed_body.dig('data', 'people')
  end

  test 'query complexity and key count remain bounded' do
    post '/graphql', params: { query: '{ people(ids: []) { manager { manager { manager { manager { name } } } } } }' },
                     headers: { 'Authorization' => 'Bearer demo-a' }, as: :json
    assert response.parsed_body['errors']
  end
end
