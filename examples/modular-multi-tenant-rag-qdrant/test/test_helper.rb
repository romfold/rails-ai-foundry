# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'
require_relative 'network_guard'
require_relative '../config/environment'
database = ActiveRecord::Base.connection_db_config.configuration_hash
unless database.fetch(:database).end_with?('_test') && %w[127.0.0.1 localhost ::1].include?(database.fetch(:host))
  abort 'Tests require a loopback database ending in _test'
end
require 'rails/test_help'
