# frozen_string_literal: true

require_relative '../config/environment'
require 'rspec/rails'

RSpec.configure do |config|
  config.before(type: :system) do
    driven_by :selenium, using: :headless_chrome do |options|
      %w[--disable-background-networking --disable-component-update --disable-sync --no-first-run].each do |argument|
        options.add_argument(argument)
      end
    end
    Capybara.server_host = '127.0.0.1'
    Capybara.default_max_wait_time = 3
  end
end
