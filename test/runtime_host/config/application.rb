# frozen_string_literal: true

require_relative 'boot'
require 'rails'
require 'action_controller/railtie'
require 'rails/test_unit/railtie'
require 'rails_ai_foundry'
require 'logger'

module FoundryRuntimeHost
  class Application < Rails::Application
    config.root = File.expand_path('..', __dir__)
    config.eager_load = Rails.env.production?
    config.enable_reloading = !Rails.env.production?
    config.secret_key_base = 'foundry-runtime-test-host-only'
    config.logger = Logger.new(File::NULL)
  end
end
