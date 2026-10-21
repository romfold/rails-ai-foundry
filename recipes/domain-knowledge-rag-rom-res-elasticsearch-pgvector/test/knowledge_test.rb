# frozen_string_literal: true

require_relative 'test_helper'

class KnowledgeTest < ActiveSupport::TestCase
  test 'lifecycle preserves authorization and rejects stale writes' do
    draft = document
    assert_empty @catalog.visible(principal: @principal)
    row = transition(draft, 'publish').value!
    assert_equal([row[:id]], @catalog.visible(principal: @principal).map { |item| item[:id] })
    assert_equal :conflict, transition(draft, 'publish').failure
    other = Access::Identity.authenticate('demo-b')
    assert_empty @catalog.list(principal: other)
    result = @catalog.change(principal: other, action: 'delete', id: row[:id], expected_revision: row[:revision])
    assert_equal :not_found, result.failure
    withdrawn = transition(row, 'withdraw').value!
    assert_empty @catalog.visible(principal: @principal)
    deleted = transition(withdrawn, 'delete').value!
    assert_empty deleted[:body]
    assert_empty @catalog.list(principal: @principal)
  end

  test 'failed result rolls back data and intent including nested success' do
    failure = Dry::Monads::Failure(:declined)
    result = @catalog.change(principal: @principal, action: 'create', attributes: { title: 'A', body: 'B' },
                             after_write: -> { failure })
    assert_equal :declined, result.failure
    assert_empty @catalog.list(principal: @principal)
    assert_empty @catalog.queue.status
    @catalog.with_write_gate do
      published
      raise Sequel::Rollback
    end
    assert_empty @catalog.list(principal: @principal)
    assert_empty @catalog.queue.status
  end

  test 'nested failed operation rolls back only its savepoint' do
    @catalog.with_write_gate do
      document(title: 'Kept')
      result = @catalog.change(principal: @principal, action: 'create', attributes: { title: 'Lost', body: 'B' },
                               after_write: -> { Dry::Monads::Failure(:declined) })
      assert result.failure?
    end
    assert_equal(['Kept'], @catalog.list(principal: @principal).map { |row| row[:title] })
    assert_equal 1, @catalog.queue.status.size
  end

  test 'publication rejects invocation inside writer transaction' do
    published
    @catalog.with_write_gate do
      assert_raises(ArgumentError) { Knowledge::PublishIntent.new(catalog: @catalog, event_store: @store).call }
    end
    assert_empty @store.read.to_a
  end

  test 'RES commit survives publisher crash and replay deduplicates' do
    document
    publisher = Knowledge::PublishIntent.new(catalog: @catalog, event_store: @store)
    assert_raises(RuntimeError) { publisher.call(after_publish: -> { raise 'crash' }) }
    assert_equal 1, @store.read.to_a.size
    ActiveRecord::Base.connection.execute("UPDATE knowledge_deliveries SET available_at = NOW() - INTERVAL '1 second'")
    assert publisher.call
    assert_equal 1, @store.read.to_a.size
    assert_equal %w[res search vectors], @catalog.queue.status.map { |row| row[:target] }.sort
  end

  test 'conflicting RES identity is quarantined rather than acknowledged' do
    document
    intent = @catalog.queue.status.first
    @store.append(Knowledge::Changed.new(event_id: intent[:event_id], data: { 'schema' => 999 }), stream_name: 'other')
    refute Knowledge::PublishIntent.new(catalog: @catalog, event_store: @store).call
    assert_equal 'poison', @catalog.queue.status.first[:state]
    assert_equal 1, @catalog.queue.status.size
  end

  test 'expired leases are fenced and poison work requires explicit repair' do
    document
    first = @catalog.queue.claim('res')
    ActiveRecord::Base.connection.execute("UPDATE knowledge_deliveries SET lease_until = NOW() - INTERVAL '1 second'")
    second = @catalog.queue.claim('res')
    refute_equal first[:lease_token], second[:lease_token]
    refute @catalog.queue.acknowledge(first)
    @catalog.queue.fail(second, code: 'invalid_schema', permanent: true)
    assert_nil @catalog.queue.claim('res')
    @catalog.queue.repair(second[:id])
    assert @catalog.queue.claim('res')
  end
  test 'competing edits allow one revision and reject the other' do
    row = document
    ready = Queue.new
    start = Queue.new
    writers = Array.new(2) do |index|
      Thread.new do
        ready << true
        start.pop
        transition(row, 'edit', attributes: { title: "Edit #{index}", body: 'Replacement' })
      end
    end
    2.times { ready.pop }
    2.times { start << true }
    results = writers.map(&:value)
    assert_equal 1, results.count(&:success?)
    assert_equal [:conflict], results.select(&:failure?).map(&:failure)
    assert_equal 2, @catalog.snapshot(row[:id])[:revision]
    assert_equal 2, @catalog.queue.status.size
  end

  test 'invalid event metadata is poison and never reaches RES' do
    @catalog.queue.enqueue(event_id: SecureRandom.uuid, target: 'res', payload: { 'schema' => 1, 'revision' => -1 })
    refute Knowledge::PublishIntent.new(catalog: @catalog, event_store: @store).call
    assert_equal 'poison', @catalog.queue.status.first[:state]
    assert_empty @store.read.to_a
  end

  test 'repeated failures quarantine work until reviewed repair' do
    document
    5.times do
      claim = @catalog.queue.claim('res')
      @catalog.queue.fail(claim, code: 'ServiceUnavailable')
      ActiveRecord::Base.connection.execute(
        "UPDATE knowledge_deliveries SET available_at = NOW() - INTERVAL '1 second'"
      )
    end
    row = @catalog.queue.status.first
    assert_equal 'poison', row[:state]
    assert_nil @catalog.queue.claim('res')
    @catalog.queue.repair(row[:id])
    assert Knowledge::PublishIntent.new(catalog: @catalog, event_store: @store).call
  end
end
