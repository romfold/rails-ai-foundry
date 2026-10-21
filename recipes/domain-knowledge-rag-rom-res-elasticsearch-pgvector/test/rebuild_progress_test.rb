# frozen_string_literal: true

require_relative 'test_helper'
require 'minitest/mock'

class RebuildProgressTest < ActiveSupport::TestCase
  test 'search resumes acknowledged candidate after crash before checkpoint' do
    row = published
    run = @search.start_rebuild(destination: 'search')
    @search.resume_rebuild(run[:id])
    assert_raises(IOError) { @search.resume_rebuild(run[:id], after_write: -> { raise IOError, 'crash' }) }
    status = @search.rebuild_status(run[:id])
    assert_nil status[:page_key]
    assert_equal run[:candidate], @search.rebuild_search(run_id: run[:id])
    assert_equal [row[:id]], @search.keyword(principal: @principal, query: 'refund').pluck(:id)
    assert_equal 'completed', @search.rebuild_status(run[:id])[:phase]
  end

  test 'catch up includes new identifiers behind the original page cursor and deletions' do
    row = published
    run = @search.start_rebuild(destination: 'search')
    @search.rebuild_search(run_id: run[:id], after_backfill: lambda {
      transition(row, 'delete').value!
      original_uuid = SecureRandom.method(:uuid)
      calls = 0
      SecureRandom.stub(:uuid, lambda {
        calls += 1
        calls == 1 ? '00000000-0000-0000-0000-000000000001' : original_uuid.call
      }) do
        published
      end
    })
    results = @search.keyword(principal: @principal, query: 'refund')
    assert_equal 1, results.size
    refute_equal row[:id], results.first[:id]
  end

  test 'expired ownership cannot checkpoint after replacement claims the run' do
    run = @search.start_rebuild(destination: 'search')
    store = Search::RebuildRuns.new(url: database_url)
    old = store.claim(run[:id])
    assert_nil store.claim(run[:id])
    ActiveRecord::Base.connection.execute("UPDATE search_rebuild_runs SET lease_until = now() - interval '1 minute'")
    replacement = store.claim(run[:id])
    refute_equal old[:lease_token], replacement[:lease_token]
    assert_raises(Search::RebuildRuns::OwnershipLost) { store.checkpoint(old, phase: 'completed') }
  ensure
    store&.disconnect
  end

  test 'cutover acknowledgment loss reconciles the selected alias and post fence changes' do
    row = published
    run = @search.start_rebuild(destination: 'search')
    @search.resume_rebuild(run[:id]) until @search.rebuild_status(run[:id])[:phase] == 'ready'
    index = @search.instance_variable_get(:@index)
    original = index.method(:guarded_cutover)
    index.stub(:guarded_cutover, lambda { |*args, **kwargs|
      original.call(*args, **kwargs)
      raise IOError, 'lost acknowledgment'
    }) do
      assert_raises(IOError) { @search.resume_rebuild(run[:id]) }
    end
    assert_equal [run[:candidate]], elastic.selected
    assert_raises(RuntimeError) { @search.cancel_rebuild(run[:id]) }
    transition(row, 'delete').value!
    assert_equal run[:candidate], @search.rebuild_search(run_id: run[:id])
    assert_empty @search.keyword(principal: @principal, query: 'refund')
  end

  test 'guarded alias request cannot undo a newer selection' do
    previous = elastic.selected.first
    first = @search.rebuild_search
    second = @search.rebuild_search
    assert_raises(Elastic::Transport::Transport::Errors::NotFound) do
      elastic.guarded_cutover(first, previous: previous)
    end
    assert_equal [second], elastic.selected
  end

  test 'cancel and dry run cleanup preserve active selection' do
    previous = elastic.selected
    run = @search.start_rebuild(destination: 'search')
    @search.resume_rebuild(run[:id])
    @search.cancel_rebuild(run[:id])
    assert @search.cleanup_rebuild(run[:id])[:dry_run]
    assert elastic.exists?(run[:candidate])
    refute @search.cleanup_rebuild(run[:id], confirm: true)[:dry_run]
    refute elastic.exists?(run[:candidate])
    assert_equal previous, elastic.selected
  end

  test 'cancelling a leased run fences its worker and defers cleanup until expiry' do
    run = @search.start_rebuild(destination: 'search')
    @search.resume_rebuild(run[:id])
    store = Search::RebuildRuns.new(url: database_url)
    owner = store.claim(run[:id])
    @search.cancel_rebuild(run[:id])
    assert_equal 'cancelled', @search.rebuild_status(run[:id])[:phase]
    assert_raises(Search::RebuildRuns::OwnershipLost) { store.checkpoint(owner, phase: 'ready') }
    assert_raises(RuntimeError) { @search.cleanup_rebuild(run[:id], confirm: true) }
    assert elastic.exists?(run[:candidate])
  ensure
    store&.disconnect
  end

  test 'resume rejects changed batch options without changing persisted progress' do
    original = Rails.configuration.x.knowledge_limits
    run = @search.start_rebuild(destination: 'search')
    Rails.configuration.x.knowledge_limits = original.merge(rebuild_page: 2)
    assert_raises(ArgumentError) { @search.resume_rebuild(run[:id]) }
    assert_equal 'queued', @search.rebuild_status(run[:id])[:phase]
  ensure
    Rails.configuration.x.knowledge_limits = original
  end

  test 'database polling recovers a rebuild without an enqueued job' do
    published
    run = @search.start_rebuild(destination: 'search')
    20.times { @search.poll_rebuilds }
    assert_equal 'completed', @search.rebuild_status(run[:id])[:phase]
    assert_equal [run[:candidate]], elastic.selected
    assert_raises(RuntimeError) { @search.cleanup_rebuild(run[:id], confirm: true) }
    @search.rebuild_search
    assert @search.cleanup_rebuild(run[:id])[:dry_run]
    assert elastic.exists?(run[:candidate])
    @search.cleanup_rebuild(run[:id], confirm: true)
    refute elastic.exists?(run[:candidate])
  end

  private

  def elastic
    Search::ElasticIndex.new(url: 'http://127.0.0.1:59210', name: 'foundry_knowledge_test')
  end

  def database_url
    config = ActiveRecord::Base.connection_db_config.configuration_hash
    "postgres://#{config[:username]}:#{config[:password]}@#{config[:host]}:#{config[:port]}/#{config[:database]}"
  end
end
