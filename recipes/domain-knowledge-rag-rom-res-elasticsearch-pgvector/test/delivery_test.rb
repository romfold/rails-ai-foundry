# frozen_string_literal: true

require_relative 'test_helper'

class DeliveryTest < ActionDispatch::IntegrationTest
  self.use_transactional_tests = false

  test 'demo UI preserves synchronous document behavior and tenant isolation' do
    get '/'
    assert_response :success
    assert_select 'h1', 'Knowledge workspace'
    post '/session', params: { token: 'demo-a' }
    assert_response :see_other
    follow_redirect!
    assert_select 'h1', 'Published knowledge'
    post '/documents', params: { title: 'HTTP refund', body: 'Return payment in 30 days' }, as: :json
    assert_response :success
    row = response.parsed_body
    patch "/documents/#{row.fetch('id')}", params: { revision: row.fetch('revision'), transition: 'publish' }, as: :json
    assert_response :success
    DeliveryPollJob.perform_now
    get '/search', params: { q: 'refund' }, as: :json
    assert_response :success
    assert_equal row.fetch('id'), response.parsed_body.first.fetch('id')
    post '/answers', params: { question: 'refund' }, as: :json
    assert_equal [row.fetch('id')], response.parsed_body.fetch('citations')
    get '/documents', headers: { 'Authorization' => 'Bearer demo-b' }, as: :json
    assert_empty response.parsed_body.fetch('documents')
  end

  test 'unauthenticated document operations do not write' do
    post '/documents', params: { title: 'Unauthorized', body: 'No' }, as: :json
    assert_response :unauthorized
  end
end
