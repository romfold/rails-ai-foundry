# frozen_string_literal: true

module Catalog
  class OutboxEntry < ApplicationRecord
    self.table_name = 'catalog_outbox_entries'
    scope :pending, -> { where(delivered_at: nil, poisoned_at: nil).where(available_at: ..Time.current) }

    def replay!
      with_lock { update!(attempts: 0, poisoned_at: nil, last_error: nil, available_at: Time.current) }
    end
  end
end
