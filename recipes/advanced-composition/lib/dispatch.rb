# frozen_string_literal: true

module Billing
  class Dispatch
    def initialize(rom:, destination:)
      @rom = rom
      @destination = destination
      @gateway = rom.gateways[:default]
      @outbox = @gateway.connection[:outbox]
    end

    def call(after_publish: -> {})
      if @gateway.connection.in_transaction?
        raise ArgumentError, 'Dispatch must run after the writer transaction commits'
      end

      @gateway.transaction do
        entry = @outbox.where(status: 'pending').for_update.skip_locked.first
        return false unless entry

        deliver?(entry, after_publish)
      end
    end

    private

    def quarantine(entry)
      @outbox.where(id: entry[:id]).update(status: 'poison', error: 'invalid amount')
    end

    def deliver?(entry, after_publish)
      order = @rom.relations[:orders].by_pk(entry[:order_id]).one!
      unless order[:cents].positive?
        quarantine(entry)
        return false
      end
      @destination.call(event_id: entry[:event_id], cents: order[:cents])
      after_publish.call
      @outbox.where(id: entry[:id]).update(status: 'delivered')
      true
    end
  end
end
