# frozen_string_literal: true

module Voice
  class Broker
    attr_reader :channel, :queue, :dead_queue

    def initialize(url: ENV.fetch('RABBITMQ_URL', 'amqp://guest:guest@127.0.0.1:55672'),
                   queue_name: "foundry.voice.#{Rails.env}")
      @connection = Bunny.new(url, automatically_recover: false, connection_timeout: 3, read_timeout: 3,
                                   continuation_timeout: 3000)
      @connection.start
      @channel = @connection.create_channel
      channel.prefetch(1)
      @dead_queue = channel.queue("#{queue_name}.dead", durable: true)
      @queue = channel.queue(queue_name, durable: true, arguments: {
                               'x-dead-letter-exchange' => '', 'x-dead-letter-routing-key' => dead_queue.name
                             })
      channel.confirm_select
      channel.default_exchange.on_return { @returned = true }
    end

    def publish(payload)
      @returned = false
      channel.default_exchange.publish(JSON.generate(payload), routing_key: queue.name, persistent: true,
                                                               mandatory: true, content_type: 'application/json')
      raise IOError, 'Broker did not confirm a routable control' unless channel.wait_for_confirms && !@returned
    end

    def close
      @connection.close
    end
  end
end
