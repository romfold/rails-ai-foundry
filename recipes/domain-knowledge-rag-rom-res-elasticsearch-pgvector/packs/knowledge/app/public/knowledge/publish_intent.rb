# frozen_string_literal: true

module Knowledge
  class PublishIntent
    class Conflict < StandardError; end

    def initialize(catalog:, event_store:)
      @catalog = catalog
      @event_store = event_store
    end

    def call(after_publish: -> {})
      raise ArgumentError, 'Publish after the writer transaction commits' if @catalog.transaction_open?

      row = @catalog.queue.claim('res')
      return false unless row

      deliver(row, after_publish)
    rescue Conflict, JSON::ParserError, KeyError => e
      @catalog.queue.fail(row, code: e.class.name, permanent: true)
      false
    rescue StandardError => e
      @catalog.queue.fail(row, code: e.class.name) if row
      raise
    end

    private

    def deliver(row, after_publish)
      publish(row)
      after_publish.call
      @catalog.queue.acknowledge(row, fanout: %w[search vectors])
    end

    def publish(row)
      payload = JSON.parse(row.fetch(:payload))
      raise Conflict, 'Unsupported event schema' unless Changed.valid_payload?(payload)

      event = Changed.new(event_id: row.fetch(:event_id), data: payload)
      stream = "knowledge-#{payload.fetch('document_id')}"
      if @event_store.event_in_stream?(event.event_id, '$all')
        verify(event, stream)
      else
        @event_store.append(event, stream_name: stream, expected_version: :any)
      end
    rescue RubyEventStore::EventDuplicatedInStream
      verify(event, stream)
    end

    def verify(event, stream)
      previous = @event_store.read.event(event.event_id)
      valid = previous.instance_of?(event.class) && previous.data == event.data &&
              @event_store.event_in_stream?(event.event_id, stream)
      raise Conflict, 'Event identity collision' unless valid
    end
  end
end
