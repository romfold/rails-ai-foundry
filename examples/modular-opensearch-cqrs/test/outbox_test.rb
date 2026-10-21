# frozen_string_literal: true

require 'test_helper'

class OutboxTest < ActiveSupport::TestCase
  def test_failed_result_rolls_back_nested_business_state_and_intent
    failing = Class.new(Catalog::SaveProduct) do
      def enqueue(product)
        super
        Failure(:rejected)
      end
    end
    Catalog::Product.transaction do
      Catalog::Product.create!(name: 'Outer')
      result = failing.new.call(name: 'Rolled back')
      assert result.failure?
      assert_equal ['Outer'], Catalog::Product.pluck(:name)
      assert_empty Catalog::OutboxEntry.all
    end
    assert Catalog::SaveProduct.new.call(name: 'Committed').success?
    assert_equal 1, Catalog::OutboxEntry.count
  end

  def test_crash_after_publication_keeps_intent_and_replay_is_idempotent
    Catalog::SaveProduct.new.call(name: 'Desk')
    delivered = {}
    publisher = ->(payload) { delivered[payload.fetch('product_id')] = 'indexed' }
    crash = -> { raise Interrupt, 'crash before acknowledgment' }
    assert_raises(Interrupt) { Catalog::DeliverOutbox.new(publisher: publisher, after_publish: crash).call }
    assert_nil Catalog::OutboxEntry.first.delivered_at
    assert Catalog::DeliverOutbox.new(publisher: publisher).call
    assert_equal 1, delivered.size
    assert_not_nil Catalog::OutboxEntry.first.delivered_at
    assert_not Catalog::DeliverOutbox.new(publisher: publisher).call
  end

  def test_poison_is_bounded_and_requires_explicit_replay
    entry = Catalog::OutboxEntry.create!(payload: {})
    worker = Catalog::DeliverOutbox.new(publisher: ->(payload) { payload.fetch('product_id') })
    3.times do
      entry.update!(available_at: Time.current)
      assert worker.call
    end
    assert_equal 3, entry.reload.attempts
    assert_not_nil entry.poisoned_at
    assert_not worker.call
    entry.replay!
    assert_nil entry.reload.poisoned_at
    assert_equal 0, entry.attempts
  end

  def test_parallel_workers_skip_locked_entries_without_duplicate_claims
    2.times { |i| Catalog::SaveProduct.new.call(name: "Product #{i}") }
    entered = Queue.new
    release = Queue.new
    published = Queue.new
    publisher = lambda do |payload|
      published << payload.fetch('product_id')
      entered << true
      release.pop
    end
    worker = Thread.new do
      ApplicationRecord.connection_pool.with_connection { Catalog::DeliverOutbox.new(publisher: publisher).call }
    end
    Timeout.timeout(5) { entered.pop }
    assert Catalog::DeliverOutbox.new(publisher: ->(payload) { published << payload.fetch('product_id') }).call
    release << true
    worker.value
    assert_equal 2, [published.pop, published.pop].uniq.length
    assert_equal 2, Catalog::OutboxEntry.where.not(delivered_at: nil).count
  ensure
    release << true if release
    worker&.join(5)
  end
end
