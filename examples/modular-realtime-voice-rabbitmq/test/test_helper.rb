# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'
require_relative 'network_guard'
require_relative '../config/environment'
database = ActiveRecord::Base.connection_db_config.configuration_hash
unless database.fetch(:database).end_with?('_test') && %w[127.0.0.1 localhost ::1].include?(database.fetch(:host))
  abort 'Tests require a loopback database ending in _test'
end
require 'rails/test_help'

module ActiveSupport
  class TestCase
    self.use_transactional_tests = false
    setup do
      Voice::Frame.delete_all
      Voice::Control.delete_all
      Voice::Receipt.delete_all
      Voice::Session.delete_all
    end
  end
end
