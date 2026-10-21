# frozen_string_literal: true

require_relative 'support'
require_relative 'event_transport'
require_relative 'index_transport'
require 'minitest/mock'

class AcceptanceTest < BenchmarkTest
  include Rack::Test::Methods

  def app
    Rails.application
  end

  def test_trusted_tenant_and_published_visibility
    mine = document
    document(tenant: 'b')
    document(published: false)
    get '/documents', { tenant_id: 'b' }, { 'HTTP_AUTHORIZATION' => 'tenant-a-token' }
    assert_equal 200, last_response.status
    assert_equal([mine.id], JSON.parse(last_response.body).map { |row| row.fetch('id') })
    get '/documents'
    assert_equal 401, last_response.status
    assert_equal 3, Knowledge::Document.count
  end

  def test_catalog_contract
    first = document
    document(tenant: 'b')
    document(published: false)
    rows = Knowledge::Catalog.list(tenant_id: 'a')
    assert_equal([first.id], rows.map { |row| row.fetch('id') })
    assert_equal %w[body id revision tenant_id], rows.first.keys.sort
    assert_equal first.body, rows.first.fetch('body')
  end

  def test_selected_task
    public_send("verify_#{ENV.fetch('BENCHMARK_TASK').tr('-', '_')}")
  end

  def verify_boundary_extraction
    id = document(revision: 7).id
    assert_equal 7, Knowledge::Catalog.list(tenant_id: 'a').first.fetch('revision')
    assert_equal id, Knowledge::Document.find(id).id
    assert_delivery_uses_catalog
  end

  def assert_delivery_uses_catalog
    calls = []
    queries = []
    rows = [{ 'id' => -1, 'tenant_id' => 'a', 'body' => 'catalog contract', 'revision' => 99 }]
    catalog = lambda do |tenant_id:|
      calls << tenant_id
      rows
    end
    subscriber = lambda do |_name, _start, _finish, _id, payload|
      queries << payload[:sql] unless payload[:name] == 'SCHEMA'
    end
    Knowledge::Catalog.stub(:list, catalog) do
      ActiveSupport::Notifications.subscribed(subscriber, 'sql.active_record') do
        get '/documents', { tenant_id: 'b' }, { 'HTTP_AUTHORIZATION' => 'tenant-a-token' }
      end
    end
    assert_equal 200, last_response.status
    assert_equal ['a'], calls
    assert_equal rows, JSON.parse(last_response.body)
    assert_empty queries, 'Delivery must delegate persistence to the public catalog'
  end

  def verify_private_coupling
    verify_authorized_tool
    paths = Dir['/candidate/{app,packs/**/app}/**/answering/retrieval_tool.rb']
    assert_equal 1, paths.size
    source = File.read(paths.first)
    assert_includes source, 'Knowledge::Catalog'
    refute_match(/Knowledge::Document/, source)
  end

  def verify_authorized_tool
    own = document
    document(tenant: 'b')
    document(published: false)
    calls = []
    tool = Answering::RetrievalTool.new(tenant_id: 'a', authorize: lambda { |tenant|
      calls << tenant
      true
    })
    assert_equal([own.id], tool.call(query: 'refund').map { |row| row.fetch('id') })
    assert_equal ['a'], calls
    assert_empty tool.call(query: 'absent')
    assert_raises(SecurityError) { tool.call(query: 'refund', tenant_id: 'b') }
    denied = Answering::RetrievalTool.new(tenant_id: 'a', authorize: ->(_tenant) { false })
    assert_raises(SecurityError) { denied.call(query: 'refund') }
  end

  def verify_stale_embedding
    %i[revision withdrawal deletion tenant].each { |mutation| check_stale_embedding(mutation) }
    current = document
    job = Knowledge::EmbeddingJob.new
    call = { document_id: current.id, tenant_id: 'a', version: 'v1' }
    assert_raises(RuntimeError) { job.call(**call, provider: ->(_body) { raise 'offline failure' }) }
    assert_empty Knowledge::Embedding.where(document_id: current.id)
    assert_equal :discarded, job.call(**call, tenant_id: 'b', provider: ->(_) { flunk 'unauthorized call' })
    %w[v1 v2].each do |version|
      assert_equal :stored, job.call(**call, version: version, provider: ->(_) { [1.0] })
    end
    assert_equal %w[v1 v2], Knowledge::Embedding.where(document_id: current.id).order(:version).pluck(:version)
    check_older_result_does_not_overwrite
  end

  def check_stale_embedding(mutation)
    current = document
    provider = lambda do |_body|
      assert_equal 0, ActiveRecord::Base.connection.open_transactions
      case mutation
      when :revision then current.update!(revision: 2, body: 'changed')
      when :withdrawal then current.update!(revision: 2, published: false)
      when :deletion then current.destroy!
      when :tenant then current.update!(tenant_id: 'b')
      end
      [0.5]
    end
    result = Knowledge::EmbeddingJob.new.call(document_id: current.id, tenant_id: 'a', version: 'v1',
                                              provider: provider)
    assert_equal :discarded, result, mutation.to_s
    assert_empty Knowledge::Embedding.where(document_id: current.id)
  end

  def check_older_result_does_not_overwrite
    current = document
    job = Knowledge::EmbeddingJob.new
    provider = lambda do |_body|
      current.update!(revision: 2)
      job.call(document_id: current.id, tenant_id: 'a', version: 'v1', provider: ->(_) { [2.0] })
      [1.0]
    end
    assert_equal :discarded, job.call(document_id: current.id, tenant_id: 'a', version: 'v1', provider: provider)
    assert_equal 2, Knowledge::Embedding.find_by!(document_id: current.id).revision
    assert_equal [2.0], JSON.parse(Knowledge::Embedding.find_by!(document_id: current.id).vector)
  end

  def verify_duplicate_delivery
    store = EventTransport.new
    delivery = Knowledge::Delivery.create!(event_id: 'stable-1', payload: JSON.generate('revision' => 1))
    publisher = Knowledge::PublishDelivery.new
    store.crash_after_write = true
    assert_raises(RuntimeError) { publisher.call(delivery_id: delivery.id, store: store) }
    refute delivery.reload.delivered
    assert_equal 1, store.events.size
    store.crash_after_write = false
    assert_equal :delivered, publisher.call(delivery_id: delivery.id, store: store)
    assert delivery.reload.delivered
    assert_equal 1, store.events.size
    [{ type: 'WrongType', data: { 'revision' => 1 } },
     { type: 'DocumentPublished', data: { 'revision' => 99 } }].each do |conflict|
      delivery.update!(delivered: false)
      store.events['stable-1'] = conflict
      assert_raises(RuntimeError) { publisher.call(delivery_id: delivery.id, store: store) }
      refute delivery.reload.delivered
    end
  end

  def verify_search_rebuild
    updated = document
    deleted = document
    withdrawn = document
    transport = IndexTransport.new
    callback = lambda do
      updated.update!(revision: 2, body: 'changed')
      deleted.destroy!
      withdrawn.update!(revision: 2, published: false)
      document(tenant: 'b', body: 'new publication')
    end
    rebuild = Knowledge::RebuildSearch.new
    rebuild.call(index: transport, after_backfill: callback)
    assert_equal(Knowledge::Document.where(published: true).order(:id).pluck(:id), transport.active.map do |row|
      row['id']
    end)
    assert_equal 'changed', transport.active.first.fetch('body')
    assert_equal 2, transport.active.first.fetch('revision')
    previous = Marshal.load(Marshal.dump(transport.active))
    transport.reject_validation = true
    assert_raises(RuntimeError) { rebuild.call(index: transport) }
    assert_equal previous, transport.active
    transport.reject_validation = false
    assert_equal 3, rebuild.call(index: transport)
    assert_equal previous, transport.active
  end
end
