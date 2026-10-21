# frozen_string_literal: true

require 'test_helper'

class DeliveryTest < ActionDispatch::IntegrationTest
  test 'HTTP ownership restricts ingestion and deletion independently of vector availability' do
    post '/documents', params: { title: 'Policy', body: 'Refund policy' }, as: :json
    assert_response :unauthorized
    post '/documents', params: { title: 'Policy', body: 'Refund policy', tenant: 'b' },
                       headers: { 'Authorization' => 'Bearer demo-a' }, as: :json
    assert_response :created
    id = response.parsed_body.fetch('id')
    assert_raises(ActiveRecord::RecordNotFound) do
      delete "/documents/#{id}", headers: { 'Authorization' => 'Bearer demo-b' }
    end
    delete "/documents/#{id}", headers: { 'Authorization' => 'Bearer demo-a' }
    assert_response :no_content
  end
end
