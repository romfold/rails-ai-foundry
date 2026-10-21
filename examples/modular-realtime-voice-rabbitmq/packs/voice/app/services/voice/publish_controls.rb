# frozen_string_literal: true

module Voice
  class PublishControls
    def initialize(broker:, after_publish: -> {})
      @broker = broker
      @after_publish = after_publish
    end

    def call
      Control.transaction do
        entry = Control.where(delivered_at: nil, poisoned_at: nil).where(available_at: ..Time.current)
                       .order(:id).lock('FOR UPDATE SKIP LOCKED').first
        return false unless entry

        deliver(entry)
      end
      true
    end

    private

    def deliver(entry)
      @broker.publish(entry.payload)
      @after_publish.call
      entry.update!(delivered_at: Time.current)
    rescue StandardError
      attempts = entry.attempts + 1
      entry.update!(attempts: attempts, available_at: Time.current + (2**attempts).seconds,
                    poisoned_at: attempts >= 3 ? Time.current : nil)
    end
  end
end
