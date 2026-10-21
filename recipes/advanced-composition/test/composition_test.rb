# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/database'
require_relative '../lib/composition'
require_relative '../lib/dispatch'

class CompositionTest < Minitest::Test
  URL = ENV.fetch('DATABASE_URL', 'postgres://postgres:foundry@127.0.0.1:55432/foundry_composition_test')

  def setup
    Billing::Database.prepare(URL)
    @rom = Billing::Database.connect(URL)
    @gateway = @rom.gateways[:default]
    @db = @gateway.connection
    @db[:outbox].delete
    @db[:orders].delete
    @db[:receipts].delete
  end

  def teardown
    @gateway&.disconnect
  end

  def test_failed_result_rolls_back_state_and_intent_inside_outer_transaction
    @gateway.transaction do
      @db[:orders].insert(cents: 7)
      result = Billing::PlaceOrder.new(rom: @rom, authorize: -> { false }).call(cents: 99)
      assert result.failure?
      assert_equal :denied, result.failure
      assert_equal [7], @db[:orders].select_map(:cents)
    end
    assert_equal 0, @db[:outbox].count
    assert_equal [7], @db[:orders].select_map(:cents)
  end

  def test_outer_rollback_removes_successful_nested_write_and_intent
    @gateway.transaction do |transaction|
      result = Billing::PlaceOrder.new(rom: @rom).call(cents: 100)
      assert result.success?
      assert_equal 1, @db[:outbox].count
      transaction.rollback!
    end
    assert_equal 0, @db[:orders].count
    assert_equal 0, @db[:outbox].count
  end

  def test_delivery_crash_retries_with_stable_identity_and_one_destination_effect
    Billing::PlaceOrder.new(rom: @rom).call(cents: 123)
    destination = ROM::SQL::Gateway.new(URL)
    consumer = lambda do |event_id:, cents:|
      destination.connection[:receipts].insert_conflict(target: :event_id).insert(event_id: event_id, cents: cents)
    end
    dispatcher = Billing::Dispatch.new(rom: @rom, destination: consumer)
    assert_raises(IOError) { dispatcher.call(after_publish: -> { raise IOError, 'crashed before acknowledgment' }) }
    assert_equal 'pending', @db[:outbox].first[:status]
    assert_equal 1, @db[:receipts].count
    assert dispatcher.call
    assert_equal 1, @db[:receipts].count
    assert_equal 'delivered', @db[:outbox].first[:status]
    refute dispatcher.call
  ensure
    destination&.disconnect
  end

  def test_uncommitted_intent_is_invisible_to_other_gateway
    observer = ROM::SQL::Gateway.new(URL)
    @gateway.transaction do
      Billing::PlaceOrder.new(rom: @rom).call(cents: 100)
      assert_equal 0, observer.connection[:outbox].count
      dispatcher = Billing::Dispatch.new(rom: @rom, destination: ->(**) { flunk 'must not publish uncommitted intent' })
      assert_raises(ArgumentError) { dispatcher.call }
    end
    assert_equal 1, observer.connection[:outbox].count
  ensure
    observer&.disconnect
  end

  def test_poison_is_quarantined_and_explicit_repair_can_replay
    Billing::PlaceOrder.new(rom: @rom).call(cents: 100)
    @db[:orders].update(cents: -1)
    dispatcher = Billing::Dispatch.new(rom: @rom, destination: ->(**) { flunk 'poison must not publish' })
    refute dispatcher.call
    assert_equal 'poison', @db[:outbox].first[:status]
    @db[:orders].update(cents: 100)
    @db[:outbox].update(status: 'pending', error: nil)
    assert Billing::Dispatch.new(rom: @rom, destination: ->(**) {}).call
  end

  def test_direct_constructor_and_optional_container_keep_native_result
    container = Billing::Composition.build(rom: @rom, authorize: -> { true })
    assert container['place_order'].call(cents: 33).success?
    denied = Billing::Composition.build(rom: @rom, authorize: -> { false })
    assert_equal :denied, denied['place_order'].call(cents: 44).failure
    assert_equal [33], @db[:orders].select_map(:cents)
    assert_nil defined?(RailsAIFoundry)
  end

  def test_trailblazer_is_a_native_alternative
    result = Billing::Quote.call(cents: 200, policy: -> { true })
    assert result.success?
    assert_equal 300, result[:total]
    refute Billing::Quote.call(cents: 200, policy: -> { false }).success?
    refute Billing::Quote.call(cents: -1, policy: -> { true }).success?
  end
end
