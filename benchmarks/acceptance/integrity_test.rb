# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/benchmark_suite/verification'
require_relative '../lib/benchmark_suite/patches'

class IntegrityTest < Minitest::Test
  WORKSPACE = Pathname(ENV.fetch('BENCHMARK_WORKSPACE')).realpath
  OUTPUT = BenchmarkSuite::Support.external_directory(ENV.fetch('BENCHMARK_EVIDENCE'))
  TASK = 'stale-embedding-rails'

  def test_new_and_deleted_files_replay
    patch = patch_for('new-deleted') do |work|
      work.join('README.md').write('A new candidate file')
      work.join('app/services/knowledge/embedding_job.rb').delete
    end
    result = verify('new-deleted', patch)
    refute_equal 'passed', result['status']
    refute_equal 'infrastructure_error', result['status']
    assert_path_exists OUTPUT.join('new-deleted/agent.patch')
  end

  def test_protected_assertions_cannot_be_disabled
    patch = patch_for('protected') { |work| work.join('test/visible_test.rb').write("puts '2 runs, 9 assertions'\n") }
    result = verify('protected', patch)
    assert_equal 'invalid_protocol', result['status']
    assert_includes result['protocol_violations'], 'test/visible_test.rb'
  end

  def test_disabled_assertions_are_rejected_by_upstream_reporter
    script = "require 'minitest/autorun'\nmodule Minitest::Assertions\n  def assert(*) = true\nend\n"
    result = verify('assertions', initializer_patch('assertions', script))
    refute_equal 'passed', result['status']
    assert_includes OUTPUT.join('assertions/verification.log').read, 'a false assertion no longer raises'
  end

  def test_skipped_requirements_cannot_pass
    script = "require 'minitest/autorun'\nMinitest::Test.class_eval { def before_setup = skip('bypassed') }\n"
    result = verify('skip', initializer_patch('skip', script))
    assert_equal 'failed', result['status']
    assert_includes OUTPUT.join('skip/checks.json').read, 'skip'
  end

  def test_forged_summary_does_not_replace_behavior
    script = "puts '3 runs, 100 assertions, 0 failures, 0 errors, 0 skips'\n"
    result = verify('forged', initializer_patch('forged', script))
    assert_equal 'failed', result['status']
    assert_equal 'failed', result.dig('foundry', 'behavioral')
  end

  def test_missing_and_corrupt_patches_are_infrastructure_errors
    missing = verify('missing', OUTPUT.join('absent.patch'))
    assert_equal 'infrastructure_error', missing['status']
    corrupt = OUTPUT.join('corrupt.patch')
    corrupt.write('not a patch')
    assert_equal 'infrastructure_error', verify('corrupt', corrupt)['status']
  end

  def test_filtered_patch_is_explicitly_non_replayable
    previous = ENV.fetch('BENCHMARK_TEST_TOKEN', nil)
    ENV['BENCHMARK_TEST_TOKEN'] = 'synthetic-evidence-secret-123'
    patch = initializer_patch('secret', "# PLACEHOLDER\n")
    insert_secret(patch)
    result = verify('secret', patch)
    assert_equal 'infrastructure_error', result['status']
    assert_includes result['message'], 'Non-replayable patch'
    refute_includes OUTPUT.join('secret/agent.patch').read, ENV.fetch('BENCHMARK_TEST_TOKEN')
  ensure
    ENV['BENCHMARK_TEST_TOKEN'] = previous
  end

  def insert_secret(patch)
    patch.write(patch.read.sub('PLACEHOLDER', ENV.fetch('BENCHMARK_TEST_TOKEN')))
  end

  def initializer_patch(name, script)
    patch_for(name) do |work|
      work.join('config/initializers').mkpath
      work.join('config/initializers/integrity_probe.rb').write(script)
    end
  end

  def verify(name, patch)
    BenchmarkSuite::Verification.new(WORKSPACE, TASK, patch, OUTPUT.join(name)).call
  end

  def patch_for(name)
    Dir.mktmpdir do |temporary|
      work = BenchmarkSuite::Patches.baseline(WORKSPACE.join('tasks', TASK), temporary)
      yield work
      BenchmarkSuite::Support.run('git', '-C', work.to_s, 'add', '-A')
      patch = OUTPUT.join("#{name}.patch")
      result = BenchmarkSuite::Support.run('git', '-C', work.to_s, 'diff', '--cached', '--binary')
      patch.write(result.fetch('output'))
      patch
    end
  end
end
