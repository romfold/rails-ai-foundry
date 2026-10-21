# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/benchmark_suite/protocol'

class ProtocolTest < Minitest::Test
  Task = Struct.new(:metadata, :verifier)
  Verifier = Struct.new(:restore_paths)

  def rules(group, paths)
    BenchmarkSuite::Protocol.rules(Task.new({ 'group' => group }, Verifier.new(paths)))
  end

  def test_upstream_application_test_edits_are_restored_without_rejecting_legitimate_references
    policy = rules(nil, %w[test saas/test bin config/environments/test.rb])
    assert_equal %w[test saas/test bin config/environments/test.rb], policy['restore']
    assert_equal %w[bin config/environments/test.rb], policy['forbidden']
  end

  def test_foundry_grading_assets_remain_protected_but_new_application_tests_are_allowed
    policy = rules('foundry', %w[Gemfile Gemfile.lock AGENTS.md TASK.md test])
    assert_includes policy['forbidden'], 'test/visible_test.rb'
    assert_includes policy['forbidden'], 'Gemfile.lock'
    refute_includes policy['forbidden'], 'test'
    assert_includes policy['restore'], 'test'
  end
end
