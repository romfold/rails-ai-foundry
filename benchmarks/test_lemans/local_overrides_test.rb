# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require_relative '../lib/benchmark_suite/local_overrides'

class LocalOverridesTest < Minitest::Test
  def test_emulation_budget_does_not_change_upstream_tests_or_requirements
    Dir.mktmpdir do |directory|
      root = Pathname(directory)
      task = seed(root)
      BenchmarkSuite::LocalOverrides.prepare(root)
      assert_equal 'Original requirements', task.join('instruction.md').read
      assert_equal({ 'verifier' => { 'timeout' => '30m' } }, YAML.safe_load_file(task.join('bench.yml')))
      assert_path_exists root.join('local-overrides.json')
      assert_equal 'FROM original-image', root.join('upstream-environments/ft-saas-billing/Dockerfile').read
    end
  end

  def seed(root)
    root.join('docker/fizzy').mkpath
    root.join('docker/fizzy/Dockerfile').write('FROM scratch')
    task = root.join('tasks/ft-saas-billing')
    task.join('environment').mkpath
    task.join('environment/Dockerfile').write('FROM original-image')
    task.join('instruction.md').write('Original requirements')
    task
  end
end
