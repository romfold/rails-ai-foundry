# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/benchmark_suite/report'

class ReportTest < Minitest::Test
  def report(records, expected)
    pairs = records.map { |row| [row.fetch('task'), row.fetch('agent')] }
    BenchmarkSuite::Report.allocate.send(:coverage, records, pairs, expected)
  end

  def row(status: 'passed', valid: true)
    { 'task' => 'one', 'agent' => 'oracle', 'status' => status, 'control_passed' => valid }
  end

  def test_missing_and_duplicate_controls_cannot_claim_completion
    refute report([], [%w[one oracle]])['accepted']
    refute report([row, row], [%w[one oracle]])['accepted']
    assert report([row], [%w[one oracle]])['accepted']
  end

  def test_infrastructure_and_protocol_failures_remain_in_denominator
    records = [row(status: 'infrastructure_error', valid: false), row(status: 'invalid_protocol', valid: false)]
    counts = BenchmarkSuite::Report.allocate.send(:counts, records)
    assert_equal 2, counts['attempted']
    assert_equal 0, counts['valid']
    assert_equal 1, counts['infrastructure_error']
    assert_equal 1, counts['invalid_protocol']
  end

  def test_expected_behavioral_failures_are_successful_negative_controls
    result = report([row(status: 'failed')], [%w[one oracle]])
    assert result['accepted']
    assert_equal 1, result['counts']['behavior_failed']
  end
end
