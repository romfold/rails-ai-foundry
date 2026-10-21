# frozen_string_literal: true

require 'test_helper'

class ScreenSystemTest < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome do |options|
    %w[--disable-background-networking --disable-component-update --disable-sync --no-first-run].each do |argument|
      options.add_argument(argument)
    end
  end
  Capybara.server_host = '127.0.0.1'
  Capybara.default_max_wait_time = 3

  test 'a browser preserves input during interaction' do
    visit '/screen?identity=reader'
    fill_in 'Draft', with: 'Unsaved text'
    click_button 'Save'
    assert_selector '#status', text: 'Saved'
    assert_field 'Draft', with: 'Unsaved text'
  end
end
