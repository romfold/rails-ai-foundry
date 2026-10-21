# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require_relative '../lib/benchmark_suite/command_paths'

class CommandPathsTest < Minitest::Test
  def check(command, *arguments)
    BenchmarkSuite::CommandPaths.check(command, arguments)
  end

  def test_replay_cannot_create_derived_files_inside_native_evidence
    Dir.mktmpdir do |root|
      assert_raises(BenchmarkSuite::Failure) { check('replay', root, root, "#{root}/derived") }
      refute_path_exists "#{root}/derived"
    end
  end

  def test_shards_cannot_recursively_copy_into_their_own_source
    Dir.mktmpdir do |root|
      assert_raises(BenchmarkSuite::Failure) { check('prepare-shard', root, "#{root}/shard", 'saas') }
      refute_path_exists "#{root}/shard"
    end
  end

  def test_symlink_ancestors_do_not_bypass_separation
    Dir.mktmpdir do |root|
      File.symlink(root, "#{root}/alias")
      assert_raises(BenchmarkSuite::Failure) { check('dependencies', root, "#{root}/alias/output") }
    end
  end

  def test_study_outputs_cannot_modify_frozen_inputs_or_results
    %w[smoke foundry upstream sources dependencies results verification preflights].each do |name|
      assert_raises(BenchmarkSuite::Failure) do
        BenchmarkSuite::CommandPaths.check('study-report', ['/tmp/study', "/tmp/study/#{name}/report"])
      end
    end
    BenchmarkSuite::CommandPaths.check('study-report', ['/tmp/study', '/tmp/study/reports/first'])
  end
end
