# frozen_string_literal: true

module Orders
  class OutboxEntry < ApplicationRecord
    self.table_name = 'orders_outbox_entries'
    scope :pending, -> { where(completed_at: nil, poisoned_at: nil) }

    def replay!
      update!(poisoned_at: nil, last_error: nil, attempts: 0, next_attempt_at: Time.current)
    end
  end
end
