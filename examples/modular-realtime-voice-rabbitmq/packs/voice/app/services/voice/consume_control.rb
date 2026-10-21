# frozen_string_literal: true

require 'digest'

module Voice
  class ConsumeControl
    class Poison < StandardError; end

    def initialize(broker:, after_apply: -> {})
      @broker = broker
      @after_apply = after_apply
    end

    def call
      delivery, _properties, body = @broker.queue.pop(manual_ack: true)
      return false unless delivery

      process(delivery, body)
      true
    end

    private

    def process(delivery, body)
      payload = JSON.parse(body)
      validate!(payload)
      apply(payload, Digest::SHA256.hexdigest(JSON.generate(payload.sort.to_h)))
      @after_apply.call
      @broker.channel.ack(delivery.delivery_tag)
    rescue JSON::ParserError, Poison, ActiveRecord::RecordNotFound
      @broker.channel.reject(delivery.delivery_tag, false)
    rescue StandardError
      # Leave transient failures unacknowledged; closing the connection requeues them.
      @broker.close
      raise
    end

    def validate!(payload)
      valid = payload.is_a?(Hash) && payload.keys.sort == %w[action epoch event_id session_id] &&
              valid_identity?(payload) && ChangeTurn::ACTIONS.include?(payload['action'])
      raise Poison, 'Invalid control envelope' unless valid
    end

    def valid_identity?(payload)
      payload['event_id'].is_a?(String) && payload['event_id'].match?(/\A[0-9a-f-]{36}\z/) &&
        payload['session_id'].is_a?(Integer) && payload['epoch'].is_a?(Integer) && payload['epoch'].positive?
    end

    def apply(payload, fingerprint)
      session = Session.find(payload.fetch('session_id'))
      session.with_lock do
        receipt = Receipt.find_by(event_id: payload.fetch('event_id'))
        if receipt
          raise Poison, 'Event identity reused with different content' unless receipt.fingerprint == fingerprint

          return
        end
        Receipt.create!(event_id: payload.fetch('event_id'), fingerprint: fingerprint)
        epoch = payload.fetch('epoch')
        session.update!(delivered_epoch: epoch) if epoch == session.epoch
      end
    end
  end
end
