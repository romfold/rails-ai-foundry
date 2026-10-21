# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require_relative '../lib/benchmark_suite/reviewed_controls'

class ReviewedStudyTest < Minitest::Test
  def setup
    @directory = Pathname(Dir.mktmpdir('reviewed-study-test-'))
    @study = BenchmarkSuite::ReviewedStudy.new(@directory.join('study'))
  end

  def teardown
    FileUtils.remove_entry(@directory)
  end

  def test_native_configuration_keeps_execution_offline_and_bounded
    config = @study.send(:configuration)
    assert_equal 'nop', config.dig('agent', 'name')
    assert_equal '20m', config.dig('agent', 'timeout')
    assert_equal 'none', config.dig('environment', 'network', 'mode')
    assert_equal '10m', config.dig('verifier', 'timeout')
    assert_includes config.dig('verifier', 'restore'), '.agents'
    assert_includes config.dig('verifier', 'restore'), 'test'
  end

  def test_candidate_contains_visible_baseline_but_no_evaluator_or_solution
    BenchmarkSuite::ReviewedStudy::GROUPS.each do |group|
      candidate = @directory.join(group)
      @study.send(:materialize, candidate, group)
      assert_candidate(candidate, group)
    end
  end

  def assert_candidate(candidate, group)
    assert_equal %w[network_guard.rb test_helper.rb visible_test.rb], candidate.join('test').children.map(&:basename)
                                                                               .map(&:to_s).sort
    assert_includes candidate.join('components/support_desk/app/services/support_desk/request_resolution.rb').read,
                    'NotImplementedError'
    refute candidate.join('solution.patch').exist?
    refute candidate.join('tests').exist?
    assert_candidate_configuration(candidate, group)
  end

  def assert_candidate_configuration(candidate, group)
    config = YAML.safe_load(candidate.join('config/foundry.yml').read)
    assert_equal 'none', config.dig('workflow', 'specs')
    assert_equal(group == 'foundry', candidate.join('Gemfile').read.include?("gem 'rails_ai_foundry'"))
  end

  def test_upstream_restore_does_not_require_absent_foundry_directories
    task = @directory.join('upstream')
    @study.send(:verifier_files, task, 'packs')
    restore = YAML.safe_load(task.join('bench.yml').read).dig('verifier', 'restore')
    refute_includes restore, '.agents'
    refute_includes restore, '.foundry'
    assert_includes restore, 'test'
  end

  def frozen_fixture
    root = @directory.join('frozen')
    root.mkpath
    root.join('task.txt').write('original')
    BenchmarkSuite::Support.json(root.join('manifest.json'), {
                                   'suite' => 'reviewed-ai-v1', 'execution_authorized' => false,
                                   'files' => BenchmarkSuite::Support.files(root)
                                 })
    root
  end

  def test_changed_input_is_rejected_before_any_grading
    root = frozen_fixture
    assert BenchmarkSuite::ReviewedControls.verify_inputs(root)
    root.join('extra.rb').write('unexpected')
    assert_raises(BenchmarkSuite::Failure) { BenchmarkSuite::ReviewedControls.verify_inputs(root) }
    root.join('extra.rb').delete
    root.join('task.txt').write('changed')
    assert_raises(BenchmarkSuite::Failure) { BenchmarkSuite::ReviewedControls.verify_inputs(root) }
  end

  def test_fault_control_requires_assertion_failure_not_crash
    root = @directory.join('result')
    root.mkpath
    log = root.join('verification.log')
    log.write('2 runs, 1 assertions, 0 failures, 1 errors')
    refute BenchmarkSuite::ReviewedControls.assertion_failure?(root)
    log.write('2 runs, 1 assertions, 1 failures, 0 errors')
    assert BenchmarkSuite::ReviewedControls.assertion_failure?(root)
  end
end
