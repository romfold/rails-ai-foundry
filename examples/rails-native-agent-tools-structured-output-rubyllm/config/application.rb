# frozen_string_literal: true

require_relative 'boot'
require 'rails'
require 'active_record/railtie'
require 'active_job/railtie'
require 'action_controller/railtie'
require 'rails/test_unit/railtie'
Bundler.require(*Rails.groups)
RubyLLM.configure do |config|
  config.use_new_acts_as = true
  config.request_timeout = 30
  config.max_retries = 0
end

module AssistanceExample
  class Application < Rails::Application
    config.load_defaults 8.1
    config.active_job.queue_adapter = :solid_queue
    config.log_level = :info
    config.filter_parameters += %i[question proposal resolution token authenticity_token]
    config.eager_load = Rails.env.production?
    config.enable_reloading = Rails.env.development?
    config.secret_key_base = ENV.fetch('SECRET_KEY_BASE', 'local-demo-only-' * 8)
    config.hosts = ['localhost', '127.0.0.1', 'www.example.com']
    config.action_controller.allow_forgery_protection = !Rails.env.test?
    config.action_dispatch.show_exceptions = :none if Rails.env.test?
  end
end
