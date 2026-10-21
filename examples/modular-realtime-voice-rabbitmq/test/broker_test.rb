# frozen_string_literal: true

require 'test_helper'

class BrokerTest < ActiveSupport::TestCase
  setup do
    @name = "foundry.voice.test.#{SecureRandom.hex(6)}"
    @broker = Voice::Broker.new(queue_name: @name)
    @session = Voice::Session.create!(tenant_id: 'a')
  end

  teardown do
    @broker.close
    cleanup = Voice::Broker.new(queue_name: @name)
    cleanup.queue.delete
    cleanup.dead_queue.delete
    cleanup.close
  end

  def test_publisher_crash_duplicate_delivery_and_consumer_reconnect
    Voice::ChangeTurn.new.call(tenant_id: 'a', session_id: @session.id, action: 'turn')
    crash = -> { raise Interrupt, 'crash after confirm' }
    assert_raises(Interrupt) { Voice::PublishControls.new(broker: @broker, after_publish: crash).call }
    assert_nil Voice::Control.first.delivered_at
    assert Voice::PublishControls.new(broker: @broker).call
    consumer_crash = -> { raise Interrupt, 'crash after database commit' }
    assert_raises(Interrupt) { Voice::ConsumeControl.new(broker: @broker, after_apply: consumer_crash).call }
    @broker.close
    @broker = Voice::Broker.new(queue_name: @name)
    consumer = Voice::ConsumeControl.new(broker: @broker)
    assert consumer.call
    assert consumer.call
    assert_equal 1, Voice::Receipt.count
    assert_equal 1, @session.reload.delivered_epoch
    assert_not consumer.call
  end

  def test_poison_dead_letters_and_stale_controls_cannot_resume_media
    Voice::ChangeTurn.new.call(tenant_id: 'a', session_id: @session.id, action: 'turn')
    old = Voice::Control.first.payload
    Voice::ChangeTurn.new.call(tenant_id: 'a', session_id: @session.id, action: 'interrupt')
    @broker.publish(Voice::Control.last.payload)
    @broker.publish(old)
    @broker.publish({ 'bad' => 'envelope' })
    consumer = Voice::ConsumeControl.new(broker: @broker)
    3.times { assert consumer.call }
    assert_equal 'idle', @session.reload.state
    assert_equal 2, @session.delivered_epoch
    assert_equal 2, Voice::Receipt.count
    delivery, _properties, body = @broker.dead_queue.pop
    assert_not_nil delivery
    assert_equal({ 'bad' => 'envelope' }, JSON.parse(body))
  end

  def test_disconnected_broker_keeps_durable_intent_for_retry
    Voice::ChangeTurn.new.call(tenant_id: 'a', session_id: @session.id, action: 'turn')
    @broker.close
    Voice::PublishControls.new(broker: @broker).call
    entry = Voice::Control.first
    assert_nil entry.delivered_at
    assert_equal 1, entry.attempts
    @broker = Voice::Broker.new(queue_name: @name)
    entry.update!(available_at: Time.current)
    assert Voice::PublishControls.new(broker: @broker).call
    assert_not_nil entry.reload.delivered_at
    assert Voice::ConsumeControl.new(broker: @broker).call
  end

  def test_unroutable_confirm_is_failure_and_identity_collision_is_poison
    @broker.queue.delete
    assert_raises(IOError) { @broker.publish({ 'bad' => 'unroutable' }) }
    @broker.close
    @broker = Voice::Broker.new(queue_name: @name)
    Voice::ChangeTurn.new.call(tenant_id: 'a', session_id: @session.id, action: 'turn')
    payload = Voice::Control.first.payload
    @broker.publish(payload)
    @broker.publish(payload.merge('action' => 'interrupt'))
    consumer = Voice::ConsumeControl.new(broker: @broker)
    assert consumer.call
    assert consumer.call
    assert_equal 1, Voice::Receipt.count
    assert_not_nil @broker.dead_queue.pop.first
  end
end
