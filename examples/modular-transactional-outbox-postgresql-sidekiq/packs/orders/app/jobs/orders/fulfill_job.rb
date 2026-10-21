# frozen_string_literal: true

module Orders
  class FulfillJob
    include Sidekiq::Job

    sidekiq_options queue: 'foundry_orders', retry: 3

    def perform(entry_id)
      entry = OutboxEntry.find(entry_id)
      entry.with_lock do
        return if entry.completed_at || entry.poisoned_at

        fulfill(entry)
      rescue ArgumentError, ActiveRecord::RecordNotFound => e
        entry.update!(poisoned_at: Time.current, last_error: e.class.name)
      end
    end

    private

    def fulfill(entry)
      payload = entry.payload
      raise ArgumentError, 'Unsupported envelope' unless payload.keys.sort == %w[order_id
                                                                                 version] && payload['version'] == 1

      order = Order.lock.find(payload.fetch('order_id'))
      Receipt.create!(outbox_entry_id: entry.id)
      order.update!(state: 'fulfilled')
      entry.update!(completed_at: Time.current)
    end
  end
end
