# frozen_string_literal: true

require 'test_helper'

class DeliveryTest < ActionDispatch::IntegrationTest
  def test_synchronous_write_durably_schedules_projection
    post '/products', params: { name: 'Desk' }, as: :json
    assert_response :unauthorized
    post '/products', params: { name: 'Desk' }, headers: { 'Authorization' => 'Bearer local-editor' }, as: :json
    assert_response :created
    assert_equal 'Desk', Catalog::Product.find(response.parsed_body.fetch('id')).name
    assert_equal 1, Catalog::OutboxEntry.count
  end
end
