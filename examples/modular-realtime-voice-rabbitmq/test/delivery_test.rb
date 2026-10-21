# frozen_string_literal: true

require 'test_helper'

class DeliveryTest < ActionDispatch::IntegrationTest
  def test_authorized_control_and_separate_pcm_transport
    post '/sessions'
    assert_response :unauthorized
    headers = { 'Authorization' => 'Bearer demo-a' }
    post '/sessions', headers: headers
    assert_response :created
    id = response.parsed_body.fetch('id')
    post "/sessions/#{id}/control", params: { action_name: 'turn' }, headers: headers, as: :json
    epoch = response.parsed_body.fetch('epoch')
    assert_equal 1, epoch
    post "/sessions/#{id}/media", params: { epoch: epoch, sequence: 0, data: Base64.strict_encode64('pcm') },
                                  headers: headers, as: :json
    assert_response :created
    get "/sessions/#{id}/media", params: { epoch: epoch }, headers: headers
    assert_equal 'pcm', Base64.strict_decode64(response.parsed_body.fetch('data'))
    assert_not Voice::Control.first.payload.key?('data')
  end

  def test_demo_view_explains_control_and_separate_media
    get '/'
    assert_response :success
    assert_select 'h1', 'Voice control and media'
    assert_select 'button#interrupt', 'Interrupt'
    assert_select 'input#recording[type=file]'
  end
end
