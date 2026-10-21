# frozen_string_literal: true

class EventTransport
  class Duplicate < StandardError
  end
  attr_reader :events
  attr_accessor :crash_after_write

  def initialize
    @events = {}
  end

  def duplicate_error
    Duplicate
  end

  def publish(id:, type:, data:)
    raise Duplicate if events.key?(id)

    events[id] = { type: type, data: data }
    raise 'crash after persistence' if crash_after_write
  end

  def read(id)
    events.fetch(id)
  end
end
