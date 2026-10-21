# frozen_string_literal: true

require 'test_helper'

class PipelineTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    Pipeline::Receipt.delete_all
    Pipeline::Cursor.delete_all
    Pipeline::Rejection.delete_all
    @receiver = Pipeline::Receive.new
  end

  test 'versioned events are ordered and idempotent and gaps retry without partial effects' do
    first = envelope(1)
    assert_equal :applied, @receiver.call(first)
    assert_equal :duplicate, @receiver.call(first)
    assert_raises(Pipeline::Receive::Gap) { @receiver.call(envelope(3)) }
    assert_equal 1, Pipeline::Receipt.count
    assert_equal :applied, @receiver.call(envelope(2, version: 2))
    assert_equal :applied, @receiver.call(envelope(3))
    assert_equal 30, Pipeline::Cursor.sole.total
    assert_equal 3, Pipeline::Cursor.sole.position
  end

  test 'malformed and reused identities quarantine without changing state' do
    @receiver.call(envelope(1))
    assert_equal :poison, @receiver.call('not-json')
    assert_equal :poison, @receiver.call(envelope(2, event_id: 'event-1'))
    assert_equal 10, Pipeline::Cursor.sole.total
    assert_equal 2, Pipeline::Rejection.count
    assert_equal :poison, @receiver.call('not-json')
    assert_equal 2, Pipeline::Rejection.count
  end

  test 'durable JetStream replays unacknowledged committed effects after reconnect and terminates poison' do
    name = "test_#{SecureRandom.hex(5)}"
    broker = Pipeline::Jetstream.new(name: name)
    broker.publish(envelope(1))
    assert_raises(Interrupt) { broker.consume(after_apply: -> { raise Interrupt }) }
    broker.close
    broker = Pipeline::Jetstream.new(name: name)
    assert_equal :duplicate, broker.consume
    assert_equal 1, Pipeline::Receipt.count
    broker.publish('invalid')
    assert_equal :poison, broker.consume
    assert_equal 1, Pipeline::Rejection.count
    assert_raises(NATS::Timeout) { broker.consume }
  ensure
    broker&.close
  end

  test 'JetStream negative acknowledgment retries a sequence gap after repair' do
    broker = Pipeline::Jetstream.new(name: "test_#{SecureRandom.hex(5)}")
    broker.publish(envelope(2))
    assert_raises(Pipeline::Receive::Gap) { broker.consume }
    @receiver.call(envelope(1))
    assert_equal :applied, broker.consume
    assert_equal 20, Pipeline::Cursor.sole.total
  ensure
    broker&.close
  end

  private

  def envelope(sequence, version: 1, event_id: "event-#{sequence}")
    JSON.generate(event_id: event_id, tenant: 'a', stream_key: 'orders', sequence: sequence,
                  version: version, (version == 1 ? :amount : :delta) => 10)
  end
end
