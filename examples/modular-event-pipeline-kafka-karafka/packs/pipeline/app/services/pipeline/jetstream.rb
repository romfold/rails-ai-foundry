# frozen_string_literal: true

module Pipeline
  class Jetstream
    attr_reader :connection, :stream, :subject

    def initialize(name: 'foundry_pipeline', url: ENV.fetch('NATS_URL', 'nats://127.0.0.1:54222'))
      @connection = NATS.connect(url, connect_timeout: 2, reconnect: false)
      @stream = name
      @subject = "#{name}.events"
      @jetstream = @connection.jetstream
      @jetstream.add_stream(name: name, subjects: [@subject], storage: 'file')
      @subscription = @jetstream.pull_subscribe(@subject, 'processor', config: { ack_wait: 1 })
    end

    def publish(raw)
      @jetstream.publish(@subject, raw)
    end

    def consume(after_apply: -> {})
      message = @subscription.fetch(1, timeout: 2).first
      result = Receive.new.call(message.data)
      after_apply.call
      result == :poison ? message.term : message.ack_sync
      result
    rescue Receive::Gap
      message.nak
      raise
    end

    def close
      @connection.close
    end
  end
end
