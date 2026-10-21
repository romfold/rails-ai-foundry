# frozen_string_literal: true

require 'test_helper'

class DeliveryTest < ActionDispatch::IntegrationTest
  def test_authorized_ingestion_retrieval_and_deletion
    post '/documents', params: { title: 'Policy', body: 'refund' }, as: :json
    assert_response :unauthorized
    headers = { 'Authorization' => 'Bearer demo-a' }
    post '/documents', params: { title: 'Policy', body: 'refund', tenant_id: 'tenant-b' }, headers: headers, as: :json
    assert_response :created
    id = response.parsed_body.fetch('id')
    get '/search', params: { question: 'refund' }, headers: { 'Authorization' => 'Bearer demo-b' }
    assert_empty response.parsed_body.fetch('passages')
    get '/search', params: { question: 'refund' }, headers: headers
    assert_equal id, response.parsed_body.fetch('passages').first.fetch('document_id')
    delete "/documents/#{id}", headers: headers
    assert_response :no_content
  end
end
