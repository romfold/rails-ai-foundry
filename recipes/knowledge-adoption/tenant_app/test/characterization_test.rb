# frozen_string_literal: true

require_relative 'test_helper'

class TenantCharacterizationTest < ActionDispatch::IntegrationTest
  AUTH = { 'Authorization' => 'Bearer demo-a' }.freeze

  test 'authorized lifecycle and optimistic conflicts preserve public behavior' do
    post '/documents', params: { collection_id: 1, title: 'Added', body: 'Body', tenant_id: 'tenant-b' },
                       headers: AUTH, as: :json
    assert_response :ok
    row = response.parsed_body
    assert_equal 'tenant-a', row['tenant_id']
    patch "/documents/#{row['id']}", params: { revision: 1, title: 'Edited', body: 'Body' }, headers: AUTH, as: :json
    assert_response :ok
    assert_equal 2, response.parsed_body['revision']
    patch "/documents/#{row['id']}", params: { revision: 1, title: 'Stale', body: 'Body' }, headers: AUTH, as: :json
    assert_response :conflict
    delete "/documents/#{row['id']}", headers: AUTH
    assert_response :no_content
  end

  test 'foreign tenants and unresolved ownership remain concealed' do
    get '/documents', headers: AUTH, as: :json
    assert_response :ok
    assert(response.parsed_body.all? { |row| row['tenant_id'] == 'tenant-a' })
    assert_operator response.parsed_body.size, :<=, 100
    [2, 4].each do |collection_id|
      post '/documents', params: { collection_id: collection_id, title: 'Denied', body: 'Denied' },
                         headers: AUTH, as: :json
      assert_response :not_found
    end
    [2, 1201].each do |id|
      patch "/documents/#{id}", params: { revision: 7, title: 'Denied', body: 'Denied' }, headers: AUTH, as: :json
      assert_response :not_found
    end
    get '/documents', as: :json
    assert_response :not_found
  end
end
