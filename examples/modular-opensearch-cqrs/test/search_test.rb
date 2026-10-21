# frozen_string_literal: true

require 'test_helper'

class SearchTest < ActiveSupport::TestCase
  setup do
    @search = Catalog::SearchIndex.new(name: "foundry_catalog_test_#{SecureRandom.hex(6)}")
  end

  teardown do
    @search.client.indices.delete(index: "#{@search.name}_*", ignore_unavailable: true)
  end

  def test_backfill_catchup_validation_atomic_cutover_and_duplicate_replay
    product = Catalog::SaveProduct.new.call(name: 'Old desk').value!
    index = Catalog::RebuildSearch.new(search: @search).call(after_backfill: lambda {
      Catalog::SaveProduct.new.call(id: product.id, name: 'Modern desk')
      Catalog::SaveProduct.new.call(name: 'Second desk')
    })
    assert_equal [index], @search.targets
    assert_equal 2, @search.search('desk').length
    publisher = @search.method(:publish)
    crash = -> { raise Interrupt, 'published but not acknowledged' }
    assert_raises(Interrupt) { Catalog::DeliverOutbox.new(publisher: publisher, after_publish: crash).call }
    worker = Catalog::DeliverOutbox.new(publisher: publisher)
    5.times { worker.call }
    assert_equal 2, @search.search('desk').length
    Catalog::SaveProduct.new.call(id: product.id, name: 'Modern desk', deleted: true)
    worker.call
    assert_equal ['Second desk'], @search.search('desk').pluck('name')
    replacement = Catalog::RebuildSearch.new(search: @search).call
    assert_equal [replacement], @search.targets
    assert @search.client.indices.exists?(index: index), 'retain old index for reviewed recovery'
  end

  def test_real_index_write_failure_preserves_state_and_recovers
    product = Catalog::SaveProduct.new.call(name: 'Desk').value!
    index = Catalog::RebuildSearch.new(search: @search).call
    @search.client.indices.put_settings(index: index, body: { 'index.blocks.write' => true })
    Catalog::SaveProduct.new.call(id: product.id, name: 'Changed desk')
    worker = Catalog::DeliverOutbox.new(publisher: @search.method(:publish))
    worker.call
    assert_equal 'Changed desk', product.reload.name
    assert_nil Catalog::OutboxEntry.first.delivered_at
    assert_equal 1, Catalog::OutboxEntry.first.attempts
    @search.client.indices.put_settings(index: index, body: { 'index.blocks.write' => false })
    Catalog::OutboxEntry.update_all(available_at: Time.current)
    3.times { worker.call }
    assert_equal ['Changed desk'], @search.search('desk').pluck('name')
  end

  def test_failed_rebuild_never_switches_alias_and_bad_candidate_fails_validation
    Catalog::SaveProduct.new.call(name: 'Desk')
    old = Catalog::RebuildSearch.new(search: @search).call
    assert_raises(IOError) do
      Catalog::RebuildSearch.new(search: @search).call(after_backfill: -> { raise IOError, 'interrupted backfill' })
    end
    assert_equal [old], @search.targets
    @search.client.index(index: old, id: 'unexpected', body: { name: 'Orphan', revision: 1, deleted: false },
                         refresh: true)
    assert_raises(RuntimeError) { Catalog::RebuildSearch.new(search: @search).validate!(old) }
    recovered = Catalog::RebuildSearch.new(search: @search).call
    assert_equal [recovered], @search.targets
    assert_equal ['Desk'], @search.search('desk').pluck('name')
  end
end
