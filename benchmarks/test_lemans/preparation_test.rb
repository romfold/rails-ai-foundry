# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require 'stringio'
require_relative '../lib/benchmark_suite/upstream'
require_relative '../lib/benchmark_suite/evidence'

class PreparationTest < Minitest::Test
  def test_repository_output_is_rejected
    assert_raises(BenchmarkSuite::Failure) do
      BenchmarkSuite::Support.external_directory(BenchmarkSuite::ROOT.join('generated'))
    end
  end

  def test_existing_output_is_preserved
    Dir.mktmpdir do |directory|
      assert_raises(BenchmarkSuite::Failure) { BenchmarkSuite::Support.external_directory(directory) }
      assert_path_exists directory
    end
  end

  def test_symlinks_are_rejected_before_fingerprinting
    Dir.mktmpdir do |directory|
      File.symlink('/etc/passwd', File.join(directory, 'secret'))
      assert_raises(BenchmarkSuite::Failure) { BenchmarkSuite::Support.files(directory) }
    end
  end

  def test_secret_filter_precedes_persistence_and_never_overwrites
    Dir.mktmpdir do |directory|
      root = File.join(directory, 'evidence')
      evidence = BenchmarkSuite::Evidence.new(root, secrets: ['synthetic-secret-123'])
      %w[stdout stderr trajectory patch].each do |name|
        result = evidence.write(name, "prefix synthetic-secret-123 suffix\n")
        assert result['sanitized']
        refute_includes File.read(File.join(root, name)), 'synthetic-secret-123'
        assert_raises(Errno::EEXIST) { evidence.write(name, 'replacement') }
      end
      assert_raises(BenchmarkSuite::Failure) { evidence.write('../escape', 'bad') }
    end
  end

  def test_environment_credentials_are_filtered
    previous = ENV.fetch('BENCHMARK_TEST_TOKEN', nil)
    ENV['BENCHMARK_TEST_TOKEN'] = 'synthetic-environment-secret'
    Dir.mktmpdir do |directory|
      evidence = BenchmarkSuite::Evidence.new(File.join(directory, 'evidence'))
      assert evidence.write('patch', ENV.fetch('BENCHMARK_TEST_TOKEN'))['sanitized']
    end
  ensure
    ENV['BENCHMARK_TEST_TOKEN'] = previous
  end

  def test_native_store_filters_text_and_streamed_artifacts_before_writing
    Dir.mktmpdir do |directory|
      filter = Lemans::SecretsFilter.new(['synthetic-native-secret'])
      store = Lemans::Stores::FS.new(directory, filterer: filter)
      result = Lemans::Result.new(task: 'filter', agent: 'nop', model: 'offline-controls')
      %w[stdout stderr trajectory.json agent.patch].each do |name|
        content = name == 'agent.patch' ? StringIO.new('synthetic-native-secret') : 'synthetic-native-secret'
        path = store.save_artifact(result, content, path: name)
        assert_equal '<filtered>', path.read
      end
    end
  end
end
