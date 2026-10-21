# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'
ENV.delete('DATABASE_URL')
abort 'Use a loopback database' unless %w[127.0.0.1 localhost ::1].include?(ENV.fetch('PGHOST', '127.0.0.1'))
require_relative '../config/environment'
require 'rails/test_help'
ActiveRecord::Migration.check_all_pending!

module ActiveSupport
  class TestCase
    self.use_transactional_tests = false
  end
end
