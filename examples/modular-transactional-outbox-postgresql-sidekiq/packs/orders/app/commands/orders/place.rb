# frozen_string_literal: true

require 'dry/operation'

module Orders
  class Place < Dry::Operation
    skip_prepending

    def call(tenant:, cents:)
      result = nil
      ApplicationRecord.transaction(requires_new: true) do
        result = steps do
          order = step persist(tenant, cents)
          step enqueue(order)
          order
        end
        raise ActiveRecord::Rollback if result.failure?
      end
      result
    end

    private

    def persist(tenant, cents)
      order = Order.new(tenant: tenant, cents: cents)
      order.save ? Success(order) : Failure(order.errors.full_messages)
    end

    def enqueue(order)
      OutboxEntry.create!(payload: { 'version' => 1, 'order_id' => order.id })
      Success(order)
    end
  end
end
