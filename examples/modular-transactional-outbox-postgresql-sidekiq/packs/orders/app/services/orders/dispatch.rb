# frozen_string_literal: true

module Orders
  class Dispatch
    def initialize(after_publish: -> {})
      @after_publish = after_publish
    end

    def call
      OutboxEntry.transaction do
        entry = OutboxEntry.pending.where(next_attempt_at: ..Time.current).lock('FOR UPDATE SKIP LOCKED').first
        return false unless entry

        FulfillJob.perform_async(entry.id)
        @after_publish.call
        # Retry until the database effect acknowledges completion, even if Redis loses a queued job.
        entry.update!(attempts: entry.attempts + 1, next_attempt_at: 10.seconds.from_now)
        true
      end
    end
  end
end
