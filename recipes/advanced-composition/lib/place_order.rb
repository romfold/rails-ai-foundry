# frozen_string_literal: true

require 'dry/operation'
require 'securerandom'

module Billing
  class PlaceOrder < Dry::Operation
    skip_prepending
    def initialize(rom:, authorize: -> { true })
      super()
      @rom = rom
      @authorize = authorize
    end

    def call(cents:)
      result = nil
      @rom.gateways[:default].transaction(savepoint: true) do |transaction|
        result = steps { persist(cents) }
        transaction.rollback! if result.failure?
      end
      result
    end

    private

    def enqueue(order)
      @rom.relations[:outbox].command(:create).call(order_id: order[:id], event_id: SecureRandom.uuid)
    end

    def persist(cents)
      step(cents.is_a?(Integer) && cents.positive? ? Success(cents) : Failure(:invalid_amount))

      order = @rom.relations[:orders].command(:create).call(cents: cents)
      step(@authorize.call ? Success(true) : Failure(:denied))
      enqueue(order)
      order
    end
  end
end
