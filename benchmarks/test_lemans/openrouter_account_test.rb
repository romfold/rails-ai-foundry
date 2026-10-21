# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/benchmark_suite/openrouter_account'

class OpenrouterAccountTest < Minitest::Test
  class FakeAccount < BenchmarkSuite::OpenrouterAccount
    def initialize(responses)
      super(key: 'synthetic-provider-api-key')
      @responses = responses
    end

    def request(path)
      @responses.fetch(path)
    end
  end

  def test_only_selected_provider_metadata_is_retained
    responses = {
      '/key' => { 'data' => { 'label' => 'sensitive-label', 'limit' => 8, 'limit_reset' => nil,
                              'usage' => 0, 'limit_remaining' => 8 } },
      '/models/openai/gpt-5.6-luna/endpoints' => { 'data' => { 'endpoints' => [
        { 'tag' => 'azure', 'status' => 0 }, { 'tag' => 'openai', 'status' => 0 }
      ] } }
    }
    result = FakeAccount.new(responses).snapshot
    assert_equal 'openai', result.dig('endpoint', 'tag')
    refute_includes JSON.generate(result), 'sensitive-label'
    refute_includes JSON.generate(result), 'synthetic-provider-api-key'
    assert_equal 64, result.fetch('key_fingerprint').length
  end

  def test_missing_metadata_is_not_silently_accepted
    account = FakeAccount.new('/key' => { 'data' => {} },
                              '/models/openai/gpt-5.6-luna/endpoints' => { 'data' => { 'endpoints' => [] } })
    assert_raises(BenchmarkSuite::Failure) { account.snapshot }
  end
end
