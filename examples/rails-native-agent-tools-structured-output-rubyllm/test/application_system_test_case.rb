# frozen_string_literal: true

require_relative 'test_helper'
require 'capybara/rails'
require 'selenium-webdriver'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [1200, 900] do |options|
    options.add_argument('--disable-background-networking')
    options.add_argument('--disable-component-update')
    options.add_argument('--disable-sync')
    options.add_argument('--no-first-run')
  end
  Capybara.server_host = '127.0.0.1'
  Capybara.default_max_wait_time = 10
end

require_relative 'support/detached_review_response'
Selenium::WebDriver::Remote::Response.prepend(DetachedReviewResponse)
