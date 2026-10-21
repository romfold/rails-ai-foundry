# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/benchmark_suite/verification'

class VerificationPhasesTest < Minitest::Test
  Task = Data.define(:verifier, :environment)
  Verifier = Data.define(:timeout, :logs_dir, :preverify, :command)
  Environment = Data.define(:workdir)

  class FakeContainer
    attr_reader :calls

    def initialize(exit_code, checks)
      @exit_code = exit_code
      @checks = checks
      @calls = []
    end

    def exec!(*) = nil

    def exec(command, **options)
      @calls << [command, options]
      code = command == 'baseline' ? @exit_code : 0
      output = command.start_with?('cat ') ? JSON.generate('checks' => @checks) : ''
      Lemans::Environment::ExecResult.new(command: command, exit_code: code, output: output, duration: 0)
    end
  end

  class FakeEvidence
    def json(*) = nil
    def write(*) = nil
  end

  def phases(code, checks)
    container = FakeContainer.new(code, checks)
    task = Task.new(verifier: Verifier.new(timeout: 60, logs_dir: '/logs',
                                           preverify: 'baseline', command: 'required'),
                    environment: Environment.new(workdir: '/app'))
    [BenchmarkSuite::VerificationPhases.new(container, task, FakeEvidence.new), container]
  end

  def test_failed_baseline_short_circuits_with_structured_evidence
    runner, container = phases(1, 'existing' => 'fail')
    assert_equal 1, runner.call.exit_code
    assert_equal 'baseline', runner.phase
    refute(container.calls.any? { |command, _| command == 'required' })
  end

  def test_existing_skips_do_not_disable_required_task_checks
    runner, container = phases(0, 'existing' => 'pass', 'optional' => 'skip')
    assert runner.call.success?
    assert_equal 'task', runner.phase
    call = container.calls.find { |command, _| command == 'required' }.last
    assert_operator call.fetch(:timeout), :<=, 60
    refute call.fetch(:env).key?('FOUNDRY_BASELINE_CHECKS')
    assert_equal '/logs', runner.checks_dir
  end

  def test_missing_and_contradictory_baseline_evidence_block_credit
    [{}, { 'existing' => 'fail' }].each do |checks|
      runner, container = phases(0, checks)
      assert_raises(BenchmarkSuite::Failure) { runner.call }
      refute(container.calls.any? { |command, _| command == 'required' })
    end
  end
end
