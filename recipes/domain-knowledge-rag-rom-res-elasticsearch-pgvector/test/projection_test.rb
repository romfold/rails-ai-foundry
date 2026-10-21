# frozen_string_literal: true

require_relative 'test_helper'

class ProjectionTest < ActiveSupport::TestCase
  test 'real search and vectors return tenant scoped current documents' do
    row = published
    drain
    assert_equal([row[:id]], @search.keyword(principal: @principal, query: 'refund').map { |item| item[:id] })
    assert_equal([row[:id]], @search.retrieve(principal: @principal, query: 'refund').fetch(:documents).map do |item|
      item[:id]
    end)
    other = Access::Identity.authenticate('demo-b')
    assert_empty @search.keyword(principal: other, query: 'refund')
    assert_empty @search.retrieve(principal: other, query: 'refund').fetch(:documents)
    transition(row, 'delete')
    assert_empty @search.keyword(principal: @principal, query: 'refund')
    assert_empty @search.retrieve(principal: @principal, query: 'refund').fetch(:documents)
    drain
    assert_equal 0, ActiveRecord::Base.connection.select_value('SELECT COUNT(*) FROM search_vectors')
  end

  test 'embedding results computed before an edit are rejected' do
    row = published
    provider = lambda do |_text|
      transition(row, 'edit', attributes: { title: 'Changed', body: 'Shipping delivery' }).value!
      Search::DemoEmbeddings.new.call('refund')
    end
    assert_raises(Search::Service::StaleRevision) do
      @search.rebuild_vectors(version: 'stale-v2', provider: provider)
    end
    assert_equal 'demo-v1', @search.active_version
    assert_equal 0, ActiveRecord::Base.connection.select_value('SELECT COUNT(*) FROM search_vectors')
  end

  test 'search backfill catches edits and deletions before cutover' do
    row = published
    drain
    candidate = @search.rebuild_search(after_backfill: -> { transition(row, 'delete').value! })
    assert_match(/foundry_knowledge_test_/, candidate)
    assert_empty @search.keyword(principal: @principal, query: 'refund')
  end

  test 'failed search validation preserves the active alias and restart succeeds' do
    published
    drain
    client = Elasticsearch::Client.new(url: 'http://127.0.0.1:59210')
    previous = client.indices.get_alias(name: 'foundry_knowledge_test').keys
    run = @search.start_rebuild(destination: 'search')
    assert_raises(RuntimeError) do
      @search.rebuild_search(run_id: run[:id], before_validate: -> { raise 'validation failed' })
    end
    assert_equal previous, client.indices.get_alias(name: 'foundry_knowledge_test').keys
    assert @search.rebuild_search(run_id: run[:id])
    assert_equal 1, @search.keyword(principal: @principal, query: 'refund').size
  end

  test 'vector cutover catches concurrent edits before activating' do
    row = published
    drain
    assert_equal 'demo-v2', @search.rebuild_vectors(version: 'demo-v2', after_backfill: lambda {
      edited = transition(row, 'edit', attributes: { title: 'New', body: 'Shipping delivery' }).value!
      transition(edited, 'publish').value!
    })
    assert_equal 'demo-v2', @search.active_version
    assert_equal 1, @search.retrieve(principal: @principal, query: 'shipping').fetch(:documents).size
  end

  test 'exhausted final write budget leaves the active search alias unchanged' do
    published
    drain
    client = Elasticsearch::Client.new(url: 'http://127.0.0.1:59210')
    previous = client.indices.get_alias(name: 'foundry_knowledge_test').keys
    assert_raises(Search::CutoverBudget::Expired) { @search.rebuild_search(gate_seconds: 0) }
    assert_equal previous, client.indices.get_alias(name: 'foundry_knowledge_test').keys
    assert_equal 1, @search.keyword(principal: @principal, query: 'refund').size
  end

  test 'old search revisions cannot resurrect deleted documents' do
    row = published
    drain
    deleted = transition(row, 'delete').value!
    index = Search::ElasticIndex.new(url: 'http://127.0.0.1:59210', name: 'foundry_knowledge_test')
    index.upsert(deleted)
    refute index.upsert(row)
    assert_empty index.query(tenant_id: @principal.tenant_id, query: 'refund')
  end
end
