# frozen_string_literal: true

module StudyProtocolTests
  def diagnosed_violation
    { 'status' => 'invalid_protocol', 'verification_phase' => 'task', 'verification_status' => 'passed',
      'reward' => 1.0, 'protocol_violations' => ['test/visible_test.rb'] }
  end

  def test_completed_protocol_violation_retains_invalid_credit_and_allows_next_trial
    complete_smoke_and_reserve_second
    record(BenchmarkSuite::Study.attempts[1], status: 'invalid_protocol', independent: diagnosed_violation)
    result = preflight(next_task, name: 'third')
    assert result['eligible']
    assert_equal 0.02, result.dig('accounting', 'reported_cost')
    assert_equal 'invalid_protocol', BenchmarkSuite::StudyResults.new(@root).records[1]['status']
  end

  def test_invalid_smoke_still_stops
    preflight
    record(status: 'invalid_protocol', independent: diagnosed_violation)
    assert_raises(BenchmarkSuite::Failure) { preflight(BenchmarkSuite::Study.attempts[1]['task'], name: 'second') }
  end

  def test_protocol_label_cannot_hide_missing_grading_or_native_failure
    complete_smoke_and_reserve_second
    [nil, diagnosed_violation.merge('verification_status' => 'infrastructure_error'),
     diagnosed_violation.merge('verification_status' => 'failed', 'reward' => 0.0),
     diagnosed_violation.merge('verification_phase' => 'baseline'),
     diagnosed_violation.merge('protocol_violations' => [])].each_with_index do |independent, index|
      reject_invalid(independent, index)
    end
    reject_native_authentication_failure
  end

  def complete_smoke_and_reserve_second
    preflight
    record
    preflight(BenchmarkSuite::Study.attempts[1]['task'], name: 'second')
  end

  def next_task
    BenchmarkSuite::Study.attempts[2]['task']
  end

  def reject_invalid(independent, index)
    row = BenchmarkSuite::Study.attempts[1]
    record(row, status: 'invalid_protocol', independent: independent)
    assert_raises(BenchmarkSuite::Failure) { preflight(next_task, name: "missing-#{index}") }
    %w[results verification].each { |directory| FileUtils.remove_entry(@root.join(directory, row['id'])) }
  end

  def reject_native_authentication_failure
    record(BenchmarkSuite::Study.attempts[1], status: 'invalid_protocol', independent: diagnosed_violation,
                                              outcome: 'authentication_error')
    assert_raises(BenchmarkSuite::Failure) { preflight(next_task, name: 'authentication') }
  end
end
