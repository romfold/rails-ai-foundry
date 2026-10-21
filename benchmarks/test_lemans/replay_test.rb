# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require_relative '../lib/benchmark_suite/replay'

class ReplayTest < Minitest::Test
  Task = Struct.new(:metadata)
  LiveTask = Data.define(:name, :metadata)

  def accepted?(independent, status = 'failed')
    task = Task.new({ 'expected_pass' => false, 'group' => 'foundry' })
    BenchmarkSuite::Replay.allocate.send(:control_passed?, task, { 'agent' => 'oracle' }, independent, status)
  end

  def test_negative_control_requires_an_actual_behavioral_assertion_failure
    refute accepted?('foundry' => { 'behavioral' => 'failed' })
    refute accepted?('foundry' => { 'behavioral' => 'infrastructure_error' }, 'assertion_failure' => true)
    assert accepted?('foundry' => { 'behavioral' => 'failed' }, 'assertion_failure' => true)
  end

  def test_disagreement_cannot_pass_a_control
    refute accepted?({ 'foundry' => { 'behavioral' => 'failed' }, 'assertion_failure' => true }, 'disagreement')
  end

  def test_interrupted_native_verification_without_reward_is_not_a_behavioral_failure
    native = { 'outcome' => { 'scored' => true }, 'reward' => nil }
    assert_equal 'infrastructure_error', BenchmarkSuite::Replay.allocate.send(:native_status, native)
  end

  def test_incomplete_native_results_remain_explicit_infrastructure_failures
    replay = BenchmarkSuite::Replay.allocate
    replay.instance_variable_set(:@tasks, {})
    Dir.mktmpdir do |directory|
      path = Pathname(directory).join('result.json')
      ['not json', 'null', '{"task":"absent","agent":"oracle"}'].each do |content|
        path.write(content)
        result = replay.send(:replay, path)
        assert_equal 'infrastructure_error', result['status']
        refute result['control_passed']
        assert_equal path.to_s, result['native_result']
      end
    end
  end

  def test_live_failures_are_measurements_not_negative_controls
    replay = BenchmarkSuite::Replay.allocate
    replay.instance_variable_set(:@live, true)
    task = LiveTask.new('stale-embedding-rails', { 'group' => 'rails' })
    native = { 'agent' => 'miniswen', 'reward' => 0, 'outcome' => { 'name' => 'completed', 'scored' => true } }
    result = replay.send(:record, task, native, { 'status' => 'failed' }, Pathname('/tmp/native.json'))
    assert_equal 'failed', result['status']
    assert_nil result['control_passed']
    native['outcome']['name'] = 'cost_ceiling_reached'
    result = replay.send(:record, task, native, { 'status' => 'passed' }, Pathname('/tmp/native.json'))
    assert_equal 'incomplete', result['status']
  end
end
