# frozen_string_literal: true

require_relative 'test_helper'

class BoundedReadsTest < ActiveSupport::TestCase
  test 'document pages traverse stable identifiers without leaking tenants or delivery history' do
    rows = Array.new(6) { document }
    other = Access::Identity.authenticate('demo-b')
    @catalog.change(principal: other, action: 'create', attributes: { title: 'Private', body: 'Private' }).value!
    ids = []
    loop do
      page = @catalog.list(principal: @principal, after: ids.last, limit: 2)
      break if page.empty?

      assert_operator page.size, :<=, 2
      ids.concat(page.pluck(:id))
      status = @catalog.delivery_status(principal: @principal, ids: page.pluck(:id))
      assert_equal page.pluck(:id).sort, status.keys.sort
      assert(status.values.all? { |deliveries| deliveries.size <= 12 })
    end
    assert_equal rows.pluck(:id).sort, ids
    assert_raises(ArgumentError) { @catalog.list(principal: @principal, limit: 101) }
  end

  test 'retrieval caps stale candidates and signals incomplete evidence' do
    row = published
    vector = Search::DemoEmbeddings.new.call('refund')
    index = Search::VectorIndex.new(url: database_url)
    101.times do |number|
      index.store(row.merge(id: format('00000000-0000-0000-0000-%012d', number), revision: 1),
                  vector, version: 'demo-v1')
    end
    result = @search.retrieve(principal: @principal, query: 'refund')
    assert_empty result.fetch(:documents)
    assert result.fetch(:incomplete)
    evidence = Answering::RetrieveEvidence.new(principal: @principal, search: @search).execute(query: 'refund')
    assert evidence.fetch('incomplete')
    assert_empty evidence.fetch('documents')
  ensure
    index&.disconnect
  end

  test 'SQL candidates exclude other tenants and versions and preserve exact tie ordering' do
    row = published
    vector = Search::DemoEmbeddings.new.call('refund')
    index = Search::VectorIndex.new(url: database_url)
    6.times do |number|
      index.store(row.merge(id: format('00000000-0000-0000-0000-%012d', number)), vector, version: 'demo-v1')
    end
    index.store(row.merge(tenant_id: 'private'), vector, version: 'demo-v1')
    index.store(row, vector, version: 'inactive')
    first = index.candidates(tenant_id: @principal.tenant_id, vector: vector, version: 'demo-v1', limit: 3)
    second = index.candidates(tenant_id: @principal.tenant_id, vector: vector, version: 'demo-v1', limit: 3,
                              after: first.last)
    assert_equal 6, (first + second).pluck(:document_id).uniq.size
    assert_equal (first + second).pluck(:document_id).sort, (first + second).pluck(:document_id)
    refute_includes (first + second).pluck(:document_id), row[:id]
  ensure
    index&.disconnect
  end

  private

  def database_url
    config = ActiveRecord::Base.connection_db_config.configuration_hash
    "postgres://#{config[:username]}:#{config[:password]}@#{config[:host]}:#{config[:port]}/#{config[:database]}"
  end
end
