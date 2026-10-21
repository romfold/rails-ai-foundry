# frozen_string_literal: true

module Search
  class DeliverProjection
    def initialize(catalog:, service:, event_store:)
      @catalog = catalog
      @service = service
      @event_store = event_store
    end

    def call(target:, after_project: -> {})
      raise ArgumentError, 'Deliver after commit' if @catalog.transaction_open?

      row = @catalog.queue.claim(target)
      return false unless row

      deliver(row, target, after_project)
    rescue ArgumentError, JSON::ParserError, KeyError => e
      @catalog.queue.fail(row, code: e.class.name, permanent: true) if row
      false
    rescue StandardError => e
      @catalog.queue.fail(row, code: e.class.name) if row
      raise
    end

    private

    def deliver(row, target, after_project)
      payload = verified_payload(row)
      @service.project(payload.fetch('document_id'), target: target)
      after_project.call
      @catalog.queue.acknowledge(row)
    end

    def verified_payload(row)
      payload = JSON.parse(row.fetch(:payload))
      stored = @event_store.read.event(row.fetch(:event_id))
      unless stored.is_a?(Knowledge::Changed) && stored.data == payload && Knowledge::Changed.valid_payload?(payload)
        raise ArgumentError, 'Projection event mismatch'
      end

      payload
    end
  end
end
