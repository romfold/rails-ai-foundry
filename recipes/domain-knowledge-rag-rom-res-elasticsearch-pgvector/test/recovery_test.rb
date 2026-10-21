# frozen_string_literal: true

require_relative 'test_helper'

class RecoveryTest < ActiveSupport::TestCase
  test 'independent workers claim different leases under contention' do
    4.times { document }
    ready = Queue.new
    start = Queue.new
    threads = Array.new(4) do
      Thread.new do
        ready << true
        start.pop
        @catalog.queue.claim('res')
      end
    end
    4.times { ready.pop }
    4.times { start << true }
    claims = threads.map(&:value)
    assert_equal 4, claims.map { |row| row.fetch(:id) }.uniq.size
    assert(claims.all? { |row| @catalog.queue.acknowledge(row) })
  end

  test 'expired claims before RES publication remain recoverable' do
    document
    @catalog.queue.claim('res')
    assert_empty @store.read.to_a
    ActiveRecord::Base.connection.execute("UPDATE knowledge_deliveries SET lease_until = NOW() - INTERVAL '1 second'")
    assert Knowledge::PublishIntent.new(catalog: @catalog, event_store: @store).call
    assert_equal 1, @store.read.to_a.size
  end

  test 'one unavailable projection does not starve another destination' do
    row = published
    events = []
    subscriber = ActiveSupport::Notifications.subscribe('delivery_failure.knowledge') { |*args| events << args.last }
    original = @search.method(:project)
    @search.define_singleton_method(:project) do |id, target:|
      raise IOError, 'Private provider details' if target == 'search'

      original.call(id, target: target)
    end
    DeliveryPollJob.perform_now
    statuses = @catalog.queue.status
    assert(statuses.select { |item| item[:target] == 'vectors' }.all? { |item| item[:state] == 'done' })
    assert(statuses.any? { |item| item[:target] == 'search' && item[:state] == 'pending' })
    assert_equal [{ target: 'search', error: 'IOError' }], events
    assert_equal([row[:id]], @search.retrieve(principal: @principal, query: 'refund').fetch(:documents).map do |item|
      item[:id]
    end)
    @search.singleton_class.remove_method(:project)
    ActiveRecord::Base.connection.execute("UPDATE knowledge_deliveries SET available_at = NOW() - INTERVAL '1 second'")
    drain
  ensure
    @search.singleton_class.remove_method(:project) if @search.singleton_methods(false).include?(:project)
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
  end

  test 'projection crash after indexing replays without duplicate results' do
    published
    publisher = Knowledge::PublishIntent.new(catalog: @catalog, event_store: @store)
    2.times { publisher.call }
    worker = Search::DeliverProjection.new(catalog: @catalog, service: @search, event_store: @store)
    assert_raises(RuntimeError) { worker.call(target: 'search', after_project: -> { raise 'crash' }) }
    ActiveRecord::Base.connection.execute("UPDATE knowledge_deliveries SET available_at = NOW() - INTERVAL '1 second'")
    drain
    assert_equal 1, @search.keyword(principal: @principal, query: 'refund').size
  end
end
