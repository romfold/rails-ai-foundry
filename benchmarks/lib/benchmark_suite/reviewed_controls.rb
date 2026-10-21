# frozen_string_literal: true

require_relative 'reviewed_study'
require_relative 'verification'

module BenchmarkSuite
  module ReviewedControls
    module_function

    def call(workspace, output)
      root = Pathname(workspace).realpath
      destination = Support.external_directory(output)
      frozen_inputs = verify_inputs(root)
      results = ReviewedStudy::GROUPS.product(ReviewedStudy::VARIANTS).map do |group, variant|
        verify_control(root, destination, group, variant)
      end
      raise Failure, 'Inputs changed during controls' unless frozen_inputs == Support.files(root)

      report = { 'suite' => 'reviewed-ai-v1', 'agent_trials' => 0,
                 'accepted' => results.all? { |row| row['accepted'] }, 'controls' => results,
                 'frozen_inputs' => frozen_inputs, 'usage' => nil, 'cost' => nil }
      Support.json(destination.join('report.json'), report)
      report
    end

    def verify_inputs(root)
      manifest = JSON.parse(root.join('manifest.json').read)
      raise Failure, 'Not an offline reviewed study' unless manifest['suite'] == 'reviewed-ai-v1' &&
                                                            manifest['execution_authorized'] == false

      actual = Support.files(root)
      expected = manifest.fetch('files')
      raise Failure, 'Frozen inputs changed' unless actual.except('manifest.json', 'images.json') == expected

      actual
    end

    def verify_control(root, destination, group, variant)
      name = "reviewed-ai-#{group}"
      patch = root.join('tasks', name, variant == 'reference' ? 'solution.patch' : "#{variant}.patch")
      output = destination.join("#{group}-#{variant}")
      started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      result = Verification.new(root, name, patch, output).call
      duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started
      expected = %w[reference delegated].include?(variant) ? 'passed' : 'failed'
      accepted = accepted?(result, expected, variant, output)
      { 'group' => group, 'variant' => variant, 'expected' => expected,
        'actual' => result['status'], 'accepted' => accepted, 'duration_seconds' => duration,
        'checks' => read_checks(output),
        'protocol_violations' => result['protocol_violations'] }
    end

    def accepted?(result, expected, variant, output)
      return false unless result['status'] == expected

      expected == 'passed' || variant == 'noop' || assertion_failure?(output)
    end

    def read_checks(output)
      path = output.join('checks.json')
      path.file? ? JSON.parse(path.read).fetch('checks', {}) : {}
    end

    def assertion_failure?(output)
      log = output.join('verification.log')
      log.file? && log.read.scan(/\d+ runs, \d+ assertions, (\d+) failures, (\d+) errors/).any? do |failures, errors|
        failures.to_i.positive? && errors.to_i.zero?
      end
    end
  end
end
