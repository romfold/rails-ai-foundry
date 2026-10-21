# frozen_string_literal: true

require 'test_helper'
require_relative 'page'

class VerificationCallerTest < ActionDispatch::IntegrationTest
  def app
    VerificationPage
  end

  test 'renders the screen through the HTTP caller' do
    get '/'
    assert_response :success
    assert_select 'button', 'Save'
  end
end
