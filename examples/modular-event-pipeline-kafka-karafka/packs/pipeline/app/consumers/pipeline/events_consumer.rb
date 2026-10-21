# frozen_string_literal: true

module Pipeline
  class EventsConsumer < Karafka::BaseConsumer
    def consume
      messages.each do |message|
        Receive.new.call(message.raw_payload)
        mark_as_consumed(message)
      end
    end
  end
end
