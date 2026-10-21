# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require_relative '../lib/benchmark_suite/corpus'

class CorpusTest < Minitest::Test
  def test_all_treatments_keep_visible_requirements_and_exclude_evaluators
    Dir.mktmpdir do |directory|
      BenchmarkSuite::Corpus::TASKS.product(BenchmarkSuite::Corpus::GROUPS).each do |task, group|
        root = Pathname(directory).join("#{task}-#{group}")
        BenchmarkSuite::Corpus.materialize(root, task, group)
        assert_candidate(root, task, group)
      end
    end
  end

  def assert_candidate(root, task, group)
    assert_equal BenchmarkSuite::ROOT.join('tasks/v1', task, 'requirements.md').read, root.join('TASK.md').read
    assert root.join('test/visible_test.rb').file?
    %w[acceptance_test.rb solution.patch .git].each { |path| refute root.join(path).exist? }
    assert_equal(group == 'foundry', root.join('config/foundry.yml').file?)
    assert_protocol_instructions(root)
  end

  def assert_protocol_instructions(root)
    instructions = root.join('AGENTS.md').read
    %w[Gemfile Gemfile.lock AGENTS.md TASK.md test/visible_test.rb test/test_helper.rb].each do |path|
      assert_includes instructions, path
    end
  end

  def test_reference_extraction_keeps_public_api_in_owning_pack
    Dir.mktmpdir do |directory|
      root = Pathname(directory).join('candidate')
      BenchmarkSuite::Corpus.materialize(root, 'boundary-extraction', 'packs', solution: 'reference')
      assert root.join('packs/knowledge/app/public/knowledge/catalog.rb').file?
      refute root.join('app/services/knowledge/catalog.rb').exist?
      assert_equal ['packs/knowledge'], YAML.safe_load_file(root.join('package.yml'))['dependencies']
    end
  end
end
