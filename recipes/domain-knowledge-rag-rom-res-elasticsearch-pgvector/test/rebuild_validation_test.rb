# frozen_string_literal: true

require_relative 'test_helper'
require 'minitest/mock'

class RebuildValidationTest < ActiveSupport::TestCase
  test 'multi page rebuild validates all identities and detects content corruption' do
    previous_limits = Rails.configuration.x.knowledge_limits
    Rails.configuration.x.knowledge_limits = previous_limits.merge(rebuild_page: 2)
    7.times { published }
    run = @search.start_rebuild(destination: 'search')
    @search.resume_rebuild(run[:id]) until @search.rebuild_status(run[:id])[:phase] == 'validating'
    ids = @catalog.list(principal: @principal).pluck(:id)
    elastic.client.index(index: run[:candidate], id: ids.first, body: { status: 'published', body: 'corrupt' },
                         refresh: true)
    assert_raises(RuntimeError) { @search.rebuild_search(run_id: run[:id]) }
    refute_equal [run[:candidate]], elastic.selected
  ensure
    Rails.configuration.x.knowledge_limits = previous_limits
  end

  test 'repeated destination failures quarantine work until explicit repair' do
    run = @search.start_rebuild(destination: 'search')
    @search.resume_rebuild(run[:id])
    elastic.delete(run[:candidate])
    5.times { assert_raises(RuntimeError) { @search.resume_rebuild(run[:id]) } }
    assert @search.rebuild_status(run[:id])[:poisoned]
    elastic.create(run[:candidate])
    assert_raises(RuntimeError) { @search.resume_rebuild(run[:id]) }
    @search.resume_rebuild(run[:id], repair: true)
    assert_equal run[:candidate], @search.rebuild_search(run_id: run[:id])
  end

  test 'oversized records fail explicitly without advancing backfill' do
    previous_limits = Rails.configuration.x.knowledge_limits
    Rails.configuration.x.knowledge_limits = previous_limits.merge(bulk_bytes: 1024)
    document(body: 'x' * 1100)
    run = @search.start_rebuild(destination: 'search')
    @search.resume_rebuild(run[:id])
    assert_raises(ArgumentError) { @search.resume_rebuild(run[:id]) }
    assert_nil @search.rebuild_status(run[:id])[:page_key]
    refute_equal [run[:candidate]], elastic.selected
  ensure
    Rails.configuration.x.knowledge_limits = previous_limits
  end

  test 'vector validation rejects corrupted embedding contents at an unchanged revision' do
    row = published
    run = @search.start_rebuild(destination: 'vectors', version: 'verify-v2')
    @search.resume_rebuild(run[:id]) until @search.rebuild_status(run[:id])[:phase] == 'validating'
    index = Search::VectorIndex.new(url: database_url)
    index.store(row, Search::DemoEmbeddings.new.call('other semantics'), version: 'verify-v2')
    assert_raises(RuntimeError) { @search.rebuild_vectors(version: 'verify-v2', run_id: run[:id]) }
    assert_equal 'demo-v1', @search.active_version
  ensure
    index&.disconnect
  end

  test 'partial bulk failure leaves checkpoint unchanged and a replay fills the same candidate' do
    2.times { published }
    run = @search.start_rebuild(destination: 'search')
    @search.resume_rebuild(run[:id])
    client = @search.instance_variable_get(:@index).client
    original = client.method(:bulk)
    client.stub(:bulk, lambda { |**arguments|
      arguments[:body] = arguments.fetch(:body).deep_dup
      arguments[:body][1][:revision] = 'invalid integer'
      original.call(**arguments)
    }) do
      assert_raises(RuntimeError) { @search.resume_rebuild(run[:id]) }
    end
    assert_nil @search.rebuild_status(run[:id])[:page_key]
    assert_equal run[:candidate], @search.rebuild_search(run_id: run[:id])
    assert_equal 2, @search.keyword(principal: @principal, query: 'refund').size
  end

  test 'three page rebuild completes without a full scan inside the final gate' do
    previous_limits = Rails.configuration.x.knowledge_limits
    Rails.configuration.x.knowledge_limits = previous_limits.merge(rebuild_page: 2)
    7.times { published }
    run = @search.start_rebuild(destination: 'search')
    @search.resume_rebuild(run[:id]) until @search.rebuild_status(run[:id])[:phase] == 'ready'
    @catalog.stub(:snapshot_page, ->(**) { raise 'Full scan in final gate' }) do
      assert_equal run[:candidate], @search.rebuild_search(run_id: run[:id])
    end
    assert_equal 7, @search.keyword(principal: @principal, query: 'refund').size
  ensure
    Rails.configuration.x.knowledge_limits = previous_limits
  end

  test 'new work at the final fence releases the gate and catches up before activation' do
    published
    run = @search.start_rebuild(destination: 'search')
    @search.resume_rebuild(run[:id]) until @search.rebuild_status(run[:id])[:phase] == 'ready'
    previous = elastic.selected
    published
    @search.resume_rebuild(run[:id])
    assert_equal 'catching_up', @search.rebuild_status(run[:id])[:phase]
    assert_equal previous, elastic.selected
    assert_equal run[:candidate], @search.rebuild_search(run_id: run[:id])
    assert_equal 2, @search.keyword(principal: @principal, query: 'refund').size
  end

  test 'withdrawal during vector validation catches up and removes all retained versions' do
    row = published
    drain
    run = @search.start_rebuild(destination: 'vectors', version: 'withdraw-v2')
    @search.resume_rebuild(run[:id]) until @search.rebuild_status(run[:id])[:phase] == 'validating'
    transition(row, 'withdraw').value!
    @search.project(row[:id], target: 'vectors')
    assert_equal 'withdraw-v2', @search.rebuild_vectors(version: 'withdraw-v2', run_id: run[:id])
    assert_equal 0, ActiveRecord::Base.connection.select_value('SELECT count(*) FROM search_vectors')
    assert_empty @search.retrieve(principal: @principal, query: 'refund').fetch(:documents)
  end

  test 'a delayed bootstrap cannot reintroduce its alias after a completed rebuild' do
    initial = elastic.selected.first
    candidate = @search.rebuild_search
    assert_raises(Elastic::Transport::Transport::Errors::BadRequest) do
      elastic.create(initial, alias_name: 'foundry_knowledge_test')
    end
    assert_equal [candidate], elastic.selected
    @search.setup
    assert_equal [candidate], elastic.selected
  end

  test 'budget expiry while reading the prior alias prevents submission' do
    published
    run = @search.start_rebuild(destination: 'search')
    @search.resume_rebuild(run[:id]) until @search.rebuild_status(run[:id])[:phase] == 'ready'
    prior = elastic.selected
    checks = 0
    budget = Object.new
    budget.define_singleton_method(:check!) do
      checks += 1
      raise Search::CutoverBudget::Expired if checks == 3
    end
    Search::CutoverBudget.stub(:new, budget) do
      assert_raises(Search::CutoverBudget::Expired) { @search.resume_rebuild(run[:id]) }
    end
    assert_equal prior, elastic.selected
    refute @search.rebuild_status(run[:id])[:cutover_intent]
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
