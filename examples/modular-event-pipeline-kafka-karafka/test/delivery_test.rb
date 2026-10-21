# frozen_string_literal: true

require 'test_helper'

class DeliveryTest < ActionDispatch::IntegrationTest
  test 'read delivery cannot select another tenant cursor' do
    key = SecureRandom.hex
    Pipeline::Cursor.create!(tenant: 'a', stream_key: key, total: 20, position: 2)
    get "/streams/#{key}"
    assert_response :unauthorized
    get "/streams/#{key}", headers: { 'Authorization' => 'Bearer demo-a' }
    assert_response :success
    assert_equal 20, response.parsed_body.fetch('total')
    assert_raises(ActiveRecord::RecordNotFound) { get "/streams/#{key}", headers: { 'Authorization' => 'Bearer demo-b' } }
  end
end
