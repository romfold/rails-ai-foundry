# frozen_string_literal: true

require_relative 'study'

module BenchmarkSuite
  module StudyBudget
    module_function

    def validate!(snapshot, previous:, first:, attempt:)
      if first && first.dig('snapshot', 'key_fingerprint') != snapshot['key_fingerprint']
        raise Failure, 'Dedicated provider key changed'
      end

      account = snapshot.fetch('account')
      validate_account(account)
      validate_endpoint(snapshot.fetch('endpoint'))
      accounting = accounting(account, previous, first)
      validate_allowance(account, accounting, attempt, first)
      accounting
    end

    def accounting(account, previous, first)
      costs = previous.map { |row| number(row.dig('native', 'usage', 'cost_usd')) }
      usage = number(account['usage'])
      initial = first ? number(first.dig('snapshot', 'account', 'usage')) : usage
      raise Failure, 'Provider usage moved backwards' if usage < initial

      { 'provider_usage_delta' => usage - initial, 'reported_cost' => costs.sum,
        'conservative_spend' => [usage - initial, costs.sum].max }
    end

    def validate_allowance(account, accounting, attempt, first)
      spent = accounting.fetch('conservative_spend')
      if spent >= Study::LIMIT || spent + attempt['cost_limit'] > Study::LIMIT
        raise Failure, 'Study allocation exhausted'
      end

      remaining = number(account['limit_remaining'])
      raise Failure, 'Insufficient key allowance' if remaining < attempt['cost_limit'] + 1.0
      raise Failure, 'First preflight needs at least $7 available' if !first && remaining < 7.0
    end

    def number(value)
      raise Failure, 'Unknown or invalid accounting' unless value.is_a?(Numeric) && value.finite? && value >= 0

      value.to_f
    end

    def validate_account(account)
      unless account['limit'] == Study::KEY_LIMIT && account['limit_reset'].nil?
        raise Failure, "Key must have a $#{Study::KEY_LIMIT.to_i} lifetime limit without reset"
      end

      number(account['usage'])
      number(account['limit_remaining'])
    end

    def validate_endpoint(endpoint)
      unless endpoint['tag'] == Study::PROVIDER && endpoint['status'].eql?(0)
        raise Failure,
              'OpenAI endpoint unavailable'
      end

      parameters = endpoint.fetch('supported_parameters')
      raise Failure, 'Tools or medium reasoning unsupported' unless (%w[tools reasoning] - parameters).empty?

      validate_prices(endpoint.fetch('pricing'))
    rescue KeyError, ArgumentError, TypeError
      raise Failure, 'Incomplete model capability or pricing metadata'
    end

    def validate_prices(pricing)
      %w[prompt completion].each do |key|
        price = Float(pricing.fetch(key))
        raise Failure, 'Invalid model pricing' unless price.finite? && price.positive?
      end
    end
  end
end
