# frozen_string_literal: true

# Register after Bundler has selected the application's Minitest version.
module FoundryBaseline
  def self.register_if_ready?
    return false unless defined?(Minitest::AbstractReporter) && Minitest.respond_to?(:extensions)

    require_relative 'minitest/foundry_baseline_plugin'
    Minitest.extensions |= ['foundry_baseline']
    true
  end
end

unless FoundryBaseline.register_if_ready?
  trace = TracePoint.new(:end) do
    trace.disable if FoundryBaseline.register_if_ready?
  end
  trace.enable
end
