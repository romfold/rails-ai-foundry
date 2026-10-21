# frozen_string_literal: true

module Catalog
  class DeliverOutbox
    MAX_ATTEMPTS = 3

    def initialize(publisher: SearchIndex.new.method(:publish), after_publish: -> {})
      @publisher = publisher
      @after_publish = after_publish
    end

    def call
      OutboxEntry.transaction do
        entry = OutboxEntry.pending.order(:id).lock('FOR UPDATE SKIP LOCKED').first
        return false unless entry

        deliver(entry)
      end
      true
    end

    private

    def deliver(entry)
      @publisher.call(entry.payload)
      @after_publish.call
      entry.update!(delivered_at: Time.current, last_error: nil)
    rescue StandardError => e
      attempts = entry.attempts + 1
      entry.update!(attempts: attempts, last_error: e.class.name, available_at: Time.current + (2**attempts).seconds,
                    poisoned_at: attempts >= MAX_ATTEMPTS ? Time.current : nil)
    end
  end
end
