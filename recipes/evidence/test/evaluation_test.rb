# frozen_string_literal: true

require 'minitest/autorun'
require 'webmock/minitest'
require_relative '../lib/live_settings'
require_relative '../lib/live_run'
require_relative '../lib/ruby_llm_provider'
WebMock.disable_net_connect!

class EvaluationTest < Minitest::Test
  ENVIRONMENT = { 'FOUNDRY_LIVE_EVAL' => '1', 'EVAL_MODEL' => 'explicit-test-model', 'EVAL_API_KEY' => 'test-key',
                  'EVAL_MAX_REQUESTS' => '2', 'EVAL_MAX_TOKENS' => '2000', 'EVAL_MAX_OUTPUT_TOKENS' => '100',
                  'EVAL_MAX_SECONDS' => '10', 'EVAL_MAX_USD' => '0.1',
                  'EVAL_INPUT_USD_PER_MILLION' => '1', 'EVAL_OUTPUT_USD_PER_MILLION' => '2' }.freeze
  CASE = { 'id' => 'one', 'prompt' => 'Return JSON',
           'expected' => { 'answer' => 'yes', 'citations' => ['one'] } }.freeze

  def test_each_required_activation_credential_and_budget_is_preflighted
    ENVIRONMENT.each_key do |key|
      env = ENVIRONMENT.dup
      env.delete(key)
      assert_raises(ArgumentError, key) { Evidence::LiveSettings.new(env) }
    end
    %w[0 -1 NaN Infinity].each do |invalid|
      assert_raises(ArgumentError) { settings('EVAL_MAX_SECONDS' => invalid) }
    end
  end

  def test_request_token_spend_and_elapsed_reservations_stop_before_network
    [{ 'EVAL_MAX_TOKENS' => '1' }, { 'EVAL_MAX_USD' => '0.000001' }].each do |override|
      result = Evidence::LiveRun.new(settings: settings(override), provider: lambda { |*|
        flunk 'must not call'
      }).call([CASE])
      assert_equal 0, result['requests']
      refute result['success']
    end
    times = [0, 11, 11]
    result = Evidence::LiveRun.new(settings: settings, provider: ->(*) { flunk 'expired' },
                                   clock: -> { times.shift || 11 }).call([CASE])
    assert_equal 0, result['requests']
    calls = 0
    provider = lambda { |*|
      calls += 1
      response
    }
    result = Evidence::LiveRun.new(settings: settings('EVAL_MAX_REQUESTS' => '1'),
                                   provider: provider).call([CASE, CASE])
    assert_equal 1, calls
    refute result['success']
  end

  def test_missing_usage_and_provider_failure_stop_further_requests
    calls = 0
    provider = lambda { |*|
      calls += 1
      response.merge('input_tokens' => nil)
    }
    result = Evidence::LiveRun.new(settings: settings, provider: provider).call([CASE, CASE])
    assert_equal 1, calls
    assert_equal 'Evidence::BudgetExceeded', result['stopped']
    failed = Evidence::LiveRun.new(settings: settings, provider: ->(*) { raise IOError }).call([CASE, CASE])
    assert_equal 1, failed['requests']
    refute failed['success']
  end

  def test_provider_output_overrun_and_timeout_stop_the_run
    provider = ->(*) { response.merge('output_tokens' => 101) }
    result = Evidence::LiveRun.new(settings: settings, provider: provider).call([CASE, CASE])
    assert_equal 1, result['requests']
    assert_equal 'Evidence::BudgetExceeded', result['stopped']
    refute result['success']
    timed_out = Evidence::LiveRun.new(settings: settings,
                                      provider: ->(*) { raise Timeout::Error }).call([CASE, CASE])
    assert_equal 1, timed_out['requests']
    refute timed_out['success']
  end

  def test_success_records_actual_usage_without_claiming_bill_cap
    result = Evidence::LiveRun.new(settings: settings, provider: ->(*) { response }).call([CASE])
    assert result['success']
    assert_equal 30, result['tokens']
    assert_in_delta 0.00005, result['estimated_usd_from_actual_usage']
    refute result['billing_cap_guaranteed']
  end

  def test_scorer_rejects_fabricated_citations_and_wrong_answers
    expected = CASE.fetch('expected')
    refute Evidence::Evaluation.score(expected: expected,
                                      actual: { 'answer' => 'yes',
                                                'citations' => ['secret'] })['passed']
    refute Evidence::Evaluation.score(expected: expected,
                                      actual: { 'answer' => 'no',
                                                'citations' => ['one'] })['passed']
    refute Evidence::Evaluation.score(expected: expected, actual: { 'answer' => 'yes', 'citations' => [] })['passed']
  end

  def test_actual_rubyllm_adapter_caps_output_and_disables_retries
    request = stub_request(:post, 'https://api.openai.com/v1/chat/completions')
              .with { |req| JSON.parse(req.body)['max_completion_tokens'] == 100 }
              .to_return(status: 503, body: '{"error":{"message":"offline failure"}}',
                         headers: { 'content-type' => 'application/json' })
    result = Evidence::LiveRun.new(settings: settings, provider: Evidence::RubyLLMProvider.new(settings)).call([CASE])
    refute result['success']
    assert_requested request, times: 1
  end

  private

  def settings(overrides = {})
    Evidence::LiveSettings.new(ENVIRONMENT.merge(overrides))
  end

  def response
    { 'answer' => CASE['expected'], 'input_tokens' => 10, 'output_tokens' => 20 }
  end
end
