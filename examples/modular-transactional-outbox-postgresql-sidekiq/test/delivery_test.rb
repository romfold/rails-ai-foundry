# frozen_string_literal: true

require 'test_helper'

class DeliveryTest < ActionDispatch::IntegrationTest
  test 'ordinary order writes are synchronous while fulfillment is durable asynchronous work' do
    post '/orders', params: { cents: 50 }, as: :json
    assert_response :unauthorized
    post '/orders', params: { cents: 50, tenant: 'b' }, headers: { 'Authorization' => 'Bearer demo-a' }, as: :json
    assert_response :created
    assert_equal 'placed', response.parsed_body.fetch('state')
    id = response.parsed_body.fetch('id')
    get "/orders/#{id}", headers: { 'Authorization' => 'Bearer demo-a' }
    assert_response :success
    assert_raises(ActiveRecord::RecordNotFound) { get "/orders/#{id}", headers: { 'Authorization' => 'Bearer demo-b' } }
  end
end
