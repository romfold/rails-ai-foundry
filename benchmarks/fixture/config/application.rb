# frozen_string_literal: true

require 'bundler/setup'
require 'rails'
require 'active_record/railtie'
require 'action_controller/railtie'
Bundler.require

module KnowledgeBenchmark
  class Application < Rails::Application
    config.load_defaults 8.1
    config.eager_load = false
    config.secret_key_base = 'offline-benchmark-' * 8
    config.hosts = ['www.example.com', 'example.org', 'localhost']
    config.logger = Logger.new($stdout)
    config.log_level = :error
  end
end
