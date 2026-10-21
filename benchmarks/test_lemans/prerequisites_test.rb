# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require_relative '../lib/benchmark_suite/prerequisites'

class PrerequisitesTest < Minitest::Test
  def test_local_prerequisites_preserve_upstream_instruction_bytes
    Dir.mktmpdir do |directory|
      root = Pathname(directory)
      task = seed(root)
      BenchmarkSuite::Prerequisites.prepare(root)
      assert_equal 'Original upstream behavior', task.join('instruction.md').read
      assert_equal 'public', YAML.safe_load_file(task.join('bench.yml')).dig('environment', 'network', 'mode')
      assert_path_exists root.join('prerequisites.json')
      assert_includes root.join('local-environments/i18n/Dockerfile').read, 'rails-i18n -v 8.1.0'
    end
  end

  def seed(root)
    root.join('docker/fizzy').mkpath
    root.join('docker/fizzy/Dockerfile').write('FROM scratch')
    task = root.join('tasks', BenchmarkSuite::Prerequisites::TASK)
    task.mkpath
    task.join('instruction.md').write('Original upstream behavior')
    task
  end
end
