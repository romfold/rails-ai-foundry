# frozen_string_literal: true

require 'test_helper'

class DeliveryTest < ActionDispatch::IntegrationTest
  test 'Rails UI and streaming delivery preserve ownership and escape output' do
    get '/'
    assert_response :success
    assert_includes response.body, 'Load saved history'
    post '/chats', headers: { 'Authorization' => 'Bearer demo-a' }
    assert_response :created
    id = response.parsed_body.fetch('id')
    post "/chats/#{id}/reply", params: { question: '<script>alert(1)</script>' },
                               headers: { 'Authorization' => 'Bearer demo-a' }, as: :json
    assert_response :success
    assert_includes response.media_type, 'turbo-stream'
    assert_includes response.body, 'action="update"'
    assert_includes response.body, '&lt;script&gt;'
    assert_not_includes response.body, '<script>'
    get "/chats/#{id}", headers: { 'Authorization' => 'Bearer demo-a' }
    assert_equal 'complete', response.parsed_body.sole.fetch('state')
    assert_raises(ActiveRecord::RecordNotFound) { get "/chats/#{id}", headers: { 'Authorization' => 'Bearer demo-b' } }
    get "/chats/#{id}"
    assert_response :unauthorized
  end
end
