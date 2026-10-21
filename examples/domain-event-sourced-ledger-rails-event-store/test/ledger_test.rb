# frozen_string_literal: true

require 'test_helper'

class LedgerTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    ActiveRecord::Base.connection.execute('TRUNCATE event_store_events_in_streams, event_store_events')
    @store = RailsEventStore::JSONClient.new
    @command = Ledger::Commands::PostMoney.new(store: @store)
  end

  test 'replay is authoritative and rejects invalid debits without appending' do
    assert post(100, -1).success?
    assert post(-30, 0).success?
    assert_equal :insufficient_funds, post(-71, 1).failure
    assert_equal :invalid_amount, post(1.5, 1).failure
    assert_equal :invalid_amount, post(0, 1).failure
    replay = Ledger::Account.new(RailsEventStore::JSONClient.new.read.stream('Ledger$a$cash').to_a)
    assert_equal 70, replay.balance
    assert_equal 1, replay.version
    assert_equal 2, @store.read.count
  end

  test 'stale writers cannot spend a balance twice' do
    assert post(100, -1).success?
    assert post(-80, 0).success?
    assert_equal :conflict, post(-80, 0).failure
    assert_equal 20, Ledger::Account.new(@store.read.stream('Ledger$a$cash').to_a).balance
  end

  test 'database expected version rejects concurrent appends' do
    event = -> { Ledger::MoneyPosted.new(data: { cents: 10 }) }
    ready = Queue.new
    release = Queue.new
    threads = 2.times.map do
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          ready << true
          release.pop
          RailsEventStore::JSONClient.new.append(event.call, stream_name: 'race', expected_version: -1)
          :saved
        rescue RubyEventStore::WrongExpectedEventVersion
          :conflict
        end
      end
    end
    2.times { ready.pop }
    2.times { release << true }
    assert_equal %i[conflict saved], threads.map(&:value).sort
    assert_equal 1, @store.read.stream('race').count
  end

  test 'outer rollback also rolls back the authoritative stream' do
    ApplicationRecord.transaction do
      assert post(100, -1).success?
      raise ActiveRecord::Rollback
    end
    assert_equal 0, @store.read.count
  end

  private

  def post(cents, version)
    @command.call(tenant: 'a', account_id: 'cash', cents: cents, expected_version: version)
  end
end
