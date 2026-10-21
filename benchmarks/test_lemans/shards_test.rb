# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/benchmark_suite/shards'

class ShardsTest < Minitest::Test
  Image = Struct.new(:context_dir)
  Task = Struct.new(:name, :environment_image)

  def shard(name, directory = '/workspace/docker/writebook')
    BenchmarkSuite::Shards.name(Task.new(name, Image.new(directory)))
  end

  def test_application_and_task_categories_remain_distinct
    assert_equal 'writebook-atomic', shard('hello-world')
    assert_equal 'writebook-atomic', shard('ar-query')
    assert_equal 'writebook-feature', shard('ft-export')
    assert_match(/\Afizzy-feature-[012]\z/, shard('ft-reactions', '/workspace/docker/fizzy'))
    assert_match(/\Afizzy-feature-[012]\z/, shard('ft-i18n-support', '/workspace/local-environments/i18n'))
    assert_equal 'fizzy-atomic', shard('ar-query', '/workspace/docker/fizzy')
    assert_equal 'saas', shard('ft-saas-billing')
  end

  def test_unknown_shard_is_rejected_before_output_creation
    assert_raises(BenchmarkSuite::Failure) { BenchmarkSuite::Shards.prepare('/missing', '/unused', 'unknown') }
  end
end
