# frozen_string_literal: true

module Evidence
  class LiveSettings
    attr_reader :model, :key, :requests, :tokens, :seconds, :usd, :output, :input_rate, :output_rate

    def initialize(env)
      raise ArgumentError, 'Explicit FOUNDRY_LIVE_EVAL=1 required' unless env['FOUNDRY_LIVE_EVAL'] == '1'

      @model = required(env, 'EVAL_MODEL')
      @key = required(env, 'EVAL_API_KEY')
      @requests = integer(env, 'EVAL_MAX_REQUESTS', 100)
      @tokens = integer(env, 'EVAL_MAX_TOKENS', 1_000_000)
      @output = integer(env, 'EVAL_MAX_OUTPUT_TOKENS', 4096)
      @seconds = number(env, 'EVAL_MAX_SECONDS', 300)
      @usd = number(env, 'EVAL_MAX_USD', 10)
      @input_rate = number(env, 'EVAL_INPUT_USD_PER_MILLION', 1000)
      @output_rate = number(env, 'EVAL_OUTPUT_USD_PER_MILLION', 1000)
    end

    private

    def required(env, name)
      value = env.fetch(name)
      raise ArgumentError, "#{name} must not be blank" unless value.is_a?(String) && !value.strip.empty?

      value
    rescue KeyError
      raise ArgumentError, "#{name} is required"
    end

    def integer(env, name, maximum)
      value = Integer(required(env, name), 10)
      raise ArgumentError, "#{name} must be between 1 and #{maximum}" unless value.between?(1, maximum)

      value
    end

    def number(env, name, maximum)
      value = Float(required(env, name))
      unless value.finite? && value.positive? && value <= maximum
        raise ArgumentError,
              "#{name} must be positive and at most #{maximum}"
      end

      value
    end
  end
end
