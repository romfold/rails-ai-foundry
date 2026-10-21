# frozen_string_literal: true

require 'test_helper'
require 'sidekiq/api'

class OutboxTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    Orders::Receipt.delete_all
    Orders::OutboxEntry.delete_all
    Orders::Order.delete_all
    Sidekiq::Queue.new('foundry_orders').clear
  end

  test 'business writes and publication intent roll back together including failed nested results' do
    assert Orders::Place.new.call(tenant: 'a', cents: 50).success?
    assert_equal 1, Orders::OutboxEntry.count
    ApplicationRecord.transaction do
      assert Orders::Place.new.call(tenant: 'a', cents: 60).success?
      raise ActiveRecord::Rollback
    end
    assert_equal 1, Orders::Order.count
    assert_equal 1, Orders::OutboxEntry.count
    failing = Class.new(Orders::Place) do
      def enqueue(_order)
        Failure(:publication_rejected)
      end
    end
    ApplicationRecord.transaction { assert failing.new.call(tenant: 'a', cents: 10).failure? }
    assert_equal 1, Orders::Order.count
    assert Orders::Place.new.call(tenant: 'a', cents: -1).failure?
  end

  test 'crash after Redis acceptance redelivers but commits the business effect once' do
    order = Orders::Place.new.call(tenant: 'a', cents: 50).value!
    entry = Orders::OutboxEntry.sole
    assert_raises(Interrupt) { Orders::Dispatch.new(after_publish: -> { raise Interrupt }).call }
    assert_equal 0, entry.reload.attempts
    assert Orders::Dispatch.new.call
    assert_equal 2, Sidekiq::Queue.new('foundry_orders').size
    2.times { Orders::FulfillJob.new.perform(entry.id) }
    assert_equal 'fulfilled', order.reload.state
    assert_equal 1, Orders::Receipt.count
    assert entry.reload.completed_at
    assert_not Orders::Dispatch.new.call
  end

  test 'lost queued jobs are recovered from PostgreSQL intent without a second business effect' do
    Orders::Place.new.call(tenant: 'a', cents: 50)
    entry = Orders::OutboxEntry.sole
    Orders::Dispatch.new.call
    Sidekiq::Queue.new('foundry_orders').clear
    entry.update!(next_attempt_at: Time.current)
    assert Orders::Dispatch.new.call
    job = Sidekiq::Queue.new('foundry_orders').first
    assert_equal [entry.id], job.args
    Orders::FulfillJob.new.perform(*job.args)
    assert_equal 1, Orders::Receipt.count
  end

  test 'poison is quarantined and explicitly repaired before replay' do
    order = Orders::Place.new.call(tenant: 'a', cents: 50).value!
    entry = Orders::OutboxEntry.sole
    entry.update!(payload: { version: 99, order_id: order.id })
    Orders::FulfillJob.new.perform(entry.id)
    assert entry.reload.poisoned_at
    assert_nil entry.completed_at
    assert_equal 'placed', order.reload.state
    assert_not Orders::Dispatch.new.call
    entry.update!(payload: { version: 1, order_id: order.id })
    entry.replay!
    Orders::FulfillJob.new.perform(entry.id)
    assert entry.reload.completed_at
    assert_equal 1, Orders::Receipt.count
  end
end
