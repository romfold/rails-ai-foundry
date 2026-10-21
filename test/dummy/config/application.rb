# frozen_string_literal: true

require_relative 'boot'
require 'rails'
require 'rails/railtie'
require 'rails_ai_foundry'
require 'socket'

class << TCPSocket
  def new(*)
    raise 'Network access is disabled in the Foundry test host'
  end
end

module FoundryTestHost
  class Application < Rails::Application
    config.root = File.expand_path('..', __dir__)
    config.eager_load = false
    config.secret_key_base = 'foundry-test-host-only'

    initializer 'foundry_test_host.reject_environment_boot' do
      raise 'The structural checker must not initialize the application environment'
    end
  end
end
