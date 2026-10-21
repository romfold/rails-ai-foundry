# frozen_string_literal: true

require 'json'

module Minitest
  # Capture the application suite without changing its existing skip semantics.
  class FoundryBaselineReporter < AbstractReporter
    def initialize(directory)
      super()
      @directory = directory
      @checks = {}
    end

    def record(result)
      @checks["#{result.klass}##{result.name}"] = status(result)
    end

    def report
      File.write(File.join(@directory, 'checks.json'), JSON.pretty_generate('checks' => @checks))
    end

    private

    def status(result)
      return 'skip' if result.skipped?
      return 'error' if result.error?

      result.passed? ? 'pass' : 'fail'
    end
  end

  def self.plugin_foundry_baseline_init(_options)
    return unless ENV['FOUNDRY_BASELINE_CHECKS'] == '1'

    reporter << FoundryBaselineReporter.new(ENV.fetch('LOGS'))
  end
end
