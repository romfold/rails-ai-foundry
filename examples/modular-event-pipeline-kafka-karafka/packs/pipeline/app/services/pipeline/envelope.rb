# frozen_string_literal: true

module Pipeline
  class Envelope
    class Invalid < StandardError; end

    def self.parse(raw)
      data = JSON.parse(raw)
      raise Invalid, 'Unsupported schema' unless data.is_a?(Hash) && [1, 2].include?(data['version'])

      amount_key = data['version'] == 1 ? 'amount' : 'delta'
      validate_fields(data, amount_key)
      validate_values(data, amount_key)

      data.merge('delta' => data.fetch(amount_key)).except('amount', 'version')
    rescue JSON::ParserError
      raise Invalid, 'Malformed JSON'
    end

    def self.validate_fields(data, amount_key)
      required = %w[event_id tenant stream_key sequence version] + [amount_key]
      raise Invalid, 'Invalid envelope fields' unless data.keys.sort == required.sort
      raise Invalid, 'Invalid identity' unless %w[event_id tenant stream_key].all? do |key|
        data[key].is_a?(String) && data[key].match?(/\A[a-zA-Z0-9_-]{1,80}\z/)
      end
    end

    def self.validate_values(data, amount_key)
      return if data['sequence'].is_a?(Integer) && data['sequence'].positive? && data[amount_key].is_a?(Integer)

      raise Invalid, 'Invalid sequence or amount'
    end
  end
end
