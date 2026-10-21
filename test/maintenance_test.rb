# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/cli'

class MaintenanceTest < FoundryTest
  def test_unknown_cli_commands_show_usage_without_writes
    [%w[unknown], %w[plan unknown]].each do |arguments|
      output = StringIO.new
      error = StringIO.new
      before = snapshot
      status = Dir.chdir(@root) { RailsAIFoundry::CLI.new.call(arguments, stdout: output, stderr: error) }
      assert_equal 1, status
      assert_includes error.string, 'Usage:'
      assert_includes error.string, 'foundry adopt'
      assert_equal before, snapshot
    end
  end
end
