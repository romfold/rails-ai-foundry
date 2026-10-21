# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/benchmark_suite/verification'

class VerificationTest < Minitest::Test
  def grade(exit_code, checks)
    result = Lemans::Environment::ExecResult.new(command: '', exit_code: exit_code, output: '', duration: 0)
    BenchmarkSuite::Verification.allocate.send(:verification_status, result, checks)
  end

  def test_forged_stdout_without_structured_checks_cannot_pass
    assert_equal 'infrastructure_error', grade(0, {})
    assert_equal 'infrastructure_error', grade(0, 'checks' => {})
  end

  def test_skipped_required_check_cannot_pass
    assert_equal 'failed', grade(0, 'checks' => { 'required' => 'skip' })
    assert_equal 'failed', grade(0, 'checks' => { 'required' => 'fail (allowed)' })
  end

  def test_native_optional_diagnostics_do_not_become_behavioral_requirements
    data = { 'checks' => { 'behavior' => 'pass', 'idiom' => 'fail (allowed)' },
             'allowed_failures' => { 'idiom' => 'manual equivalent implementation' } }
    assert_equal 'passed', grade(0, data)
  end

  def test_timeout_and_reporter_abort_are_infrastructure_errors
    [124, 137, 2].each do |code|
      assert_equal 'infrastructure_error', grade(code, 'checks' => { 'required' => 'pass' })
    end
  end
end
