# frozen_string_literal: true

require_relative 'boot'
require 'rails'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
require 'active_job/railtie'
require 'rails/test_unit/railtie'
Bundler.require(*Rails.groups)
module KnowledgeWorkspace
  class Application < Rails::Application
    config.load_defaults 8.1
    config.eager_load = Rails.env.production?
    config.secret_key_base = ENV.fetch('SECRET_KEY_BASE', 'local-knowledge-demo-' * 8)
    config.hosts = ['localhost', '127.0.0.1', 'www.example.com']
    config.active_record.schema_format = :sql
    config.active_job.queue_adapter = :solid_queue
    config.action_dispatch.show_exceptions = :none if Rails.env.test?
  end
end
