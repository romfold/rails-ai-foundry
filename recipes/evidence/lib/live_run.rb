# frozen_string_literal: true

require 'timeout'
require_relative 'evaluation'

module Evidence
  class BudgetExceeded < StandardError; end

  class LiveRun
    def initialize(settings:, provider:, clock: -> { Process.clock_gettime(Process::CLOCK_MONOTONIC) })
      @settings = settings
      @provider = provider
      @clock = clock
    end

    def call(cases)
      @started = @clock.call
      report = initial_report
      validate_cases!(cases)

      cases.each { |item| evaluate(item, report) }
      report['success'] = passed?(report)
      report
    rescue StandardError => e
      report['stopped'] = e.class.name
      report
    ensure
      report['elapsed_seconds'] = @clock.call - @started if report
    end

    private

    def initial_report
      { 'model' => @settings.model, 'requests' => 0, 'tokens' => 0, 'estimated_usd_from_actual_usage' => 0.0,
        'results' => [], 'success' => false, 'billing_cap_guaranteed' => false,
        'limits' => { 'requests' => @settings.requests, 'tokens' => @settings.tokens, 'seconds' => @settings.seconds,
                      'usd' => @settings.usd, 'output_tokens_per_request' => @settings.output },
        'pricing_usd_per_million' => { 'input' => @settings.input_rate, 'output' => @settings.output_rate } }
    end

    def evaluate(item, report)
      prompt = item.fetch('prompt')
      validate_prompt!(prompt)
      remaining = remaining_seconds
      check_budget!(report, prompt.bytesize + 512 + @settings.output, remaining)
      report['requests'] += 1
      response = Timeout.timeout(remaining) { @provider.call(prompt, output: @settings.output, timeout: remaining) }
      record_usage(response, report)
      record_score(item, response, report)
    end

    def remaining_seconds
      @settings.seconds - (@clock.call - @started)
    end

    def record_score(item, response, report)
      report['results'] << { 'id' => item.fetch('id'),
                             'score' => Evaluation.score(expected: item.fetch('expected'),
                                                         actual: response.fetch('answer')) }
    end

    def validate_cases!(cases)
      return if cases.is_a?(Array) && !cases.empty?

      raise ArgumentError, 'Nonempty evaluation cases required'
    end

    def passed?(report)
      report['results'].all? { |item| item.fetch('score').fetch('passed') }
    end

    def validate_prompt!(prompt)
      return if prompt.is_a?(String) && prompt.bytesize <= 16_000

      raise ArgumentError, 'Prompt must be bounded text'
    end

    def record_usage(response, report)
      input, output = response.values_at('input_tokens', 'output_tokens')
      unless [input, output].all? { |value| value.is_a?(Integer) && value >= 0 }
        raise BudgetExceeded, 'Unknown usage: no further requests allowed'
      end

      report['tokens'] += input + output
      report['estimated_usd_from_actual_usage'] += cost(input, output)
      (report['usage'] ||= []) << { 'input_tokens' => input, 'output_tokens' => output }
      raise BudgetExceeded, 'Provider exceeded reserved limits' unless within_limits?(report, output)
    end

    def within_limits?(report, output)
      report['tokens'] <= @settings.tokens && output <= @settings.output &&
        report['estimated_usd_from_actual_usage'] <= @settings.usd
    end

    def check_budget!(report, reservation, remaining)
      return if report['requests'] < @settings.requests && remaining.positive? &&
                report['tokens'] + reservation <= @settings.tokens &&
                report['estimated_usd_from_actual_usage'] + cost(reservation, @settings.output) <= @settings.usd

      raise BudgetExceeded, 'Request, token, time or spend reservation exhausted'
    end

    def cost(input, output)
      ((input * @settings.input_rate) + (output * @settings.output_rate)) / 1_000_000.0
    end
  end
end
