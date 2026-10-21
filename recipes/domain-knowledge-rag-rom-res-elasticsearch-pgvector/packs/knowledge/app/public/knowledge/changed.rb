# frozen_string_literal: true

module Knowledge
  class Changed < RubyEventStore::Event
    def self.valid_payload?(payload)
      payload.is_a?(Hash) && payload.keys.sort == %w[document_id revision schema tenant_id] &&
        payload['schema'] == 1 && valid_identity?(payload) &&
        payload['revision'].is_a?(Integer) && payload['revision'].positive?
    end

    def self.valid_identity?(payload)
      payload['document_id'].is_a?(String) &&
        payload['document_id'].match?(/\A[0-9a-f]{8}-(?:[0-9a-f]{4}-){3}[0-9a-f]{12}\z/) &&
        payload['tenant_id'].is_a?(String) && !payload['tenant_id'].empty?
    end
  end
end
