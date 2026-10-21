# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/benchmark_run'

class BenchmarkTest < Minitest::Test
  def test_rejects_fast_but_incorrect_implementation
    runner = Evidence::BenchmarkRun.new
    assert_raises(RuntimeError) { runner.verify!('broken' => ->(**) { true }) }
  end

  def test_records_paired_repeated_samples_only_after_behavior_passes
    result = Evidence::BenchmarkRun.new.call(trials: 5, iterations: 2)
    assert result['held_out_passed']
    assert_equal 10, result['samples'].size
    assert_equal(%w[vanilla_rails foundry_native foundry_native vanilla_rails], result['samples'].first(4).map do |s|
      s['subject']
    end)
    assert(result['samples'].all? { |s| s['elapsed_seconds'].positive? && s['allocations'].positive? })
  end
end
