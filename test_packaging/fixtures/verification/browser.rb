# frozen_string_literal: true

require 'application_system_test_case'
require_relative 'page'

class VerificationBrowserTest < ApplicationSystemTestCase
  setup { Capybara.app = VerificationPage }

  test 'a real browser executes the screen interaction' do
    visit '/'
    fill_in 'Draft', with: 'Unsaved text'
    click_button 'Save'
    assert_selector '#status', text: 'Saved'
    assert_field 'Draft', with: 'Unsaved text'
  end
end
