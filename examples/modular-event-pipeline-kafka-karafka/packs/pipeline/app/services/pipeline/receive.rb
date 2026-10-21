# frozen_string_literal: true

require 'digest'

module Pipeline
  class Receive
    class Gap < StandardError; end

    def call(raw)
      data = Envelope.parse(raw)
      fingerprint = Digest::SHA256.hexdigest(JSON.generate(data.sort.to_h))
      Cursor.transaction do
        cursor = Cursor.create_or_find_by!(tenant: data.fetch('tenant'), stream_key: data.fetch('stream_key'))
        cursor.with_lock { apply(cursor, data, fingerprint) }
      end
    rescue Envelope::Invalid => e
      quarantine(raw, e.message)
      :poison
    end

    private

    def quarantine(raw, reason)
      Rejection.find_or_create_by!(fingerprint: Digest::SHA256.hexdigest(raw)) do |rejection|
        rejection.payload = raw
        rejection.reason = reason
      end
    end

    def apply(cursor, data, fingerprint)
      receipt = Receipt.find_by(event_id: data.fetch('event_id'))
      if receipt
        raise Envelope::Invalid, 'Event identity reused' unless receipt.fingerprint == fingerprint

        return :duplicate
      end
      raise Gap, 'Sequence gap or stale event identity' unless data.fetch('sequence') == cursor.position + 1

      Receipt.create!(event_id: data.fetch('event_id'), fingerprint: fingerprint)
      cursor.update!(position: data.fetch('sequence'), total: cursor.total + data.fetch('delta'))
      :applied
    end
  end
end
