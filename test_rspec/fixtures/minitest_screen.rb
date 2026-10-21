# frozen_string_literal: true

require 'test_helper'

class ScreenTest < ActionDispatch::IntegrationTest
  test 'conceals another tenant and permits the authorized caller' do
    get '/screen', params: { identity: 'foreign' }
    assert_response :not_found
    get '/screen', params: { identity: 'reader' }
    assert_response :success
    assert_includes response.body, 'Draft'
  end
end
