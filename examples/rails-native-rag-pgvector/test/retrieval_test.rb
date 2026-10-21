# frozen_string_literal: true

require 'test_helper'

class RetrievalTest < ActiveSupport::TestCase
  def test_tenant_scoping_citations_and_offline_retrieval_quality
    ingest = Knowledge::Ingest.new
    refund = ingest.call(tenant_id: 'a', title: 'Refund policy', body: 'Return money for a refund within 30 days.')
    ingest.call(tenant_id: 'a', title: 'Shipping', body: 'Parcel delivery shipping takes five days.')
    ingest.call(tenant_id: 'b', title: 'Private', body: 'refund')
    result = Knowledge::Retrieve.new.call(tenant_id: 'a', question: 'refund', limit: 1)
    assert_equal [refund.id], result.pluck('document_id')
    assert_equal "document:#{refund.id}#passage-0", result.first.fetch('citation')
    assert_equal 'Refund policy', result.first.fetch('title')
    assert_empty Knowledge::Retrieve.new.call(tenant_id: 'unknown', question: 'refund')
    queries = { 'return money' => 'Refund policy', 'parcel shipping' => 'Shipping' }
    hits = queries.count do |question, title|
      Knowledge::Retrieve.new.call(tenant_id: 'a', question: question, limit: 1).first.fetch('title') == title
    end
    assert_equal 1.0, hits.fdiv(queries.size), 'deterministic recall@1 must equal 1.0'
  end

  def test_versions_deletion_and_unavailable_provider_are_atomic
    document = Knowledge::Ingest.new.call(tenant_id: 'a', title: 'Policy', body: "refund\n\nshipping")
    failing = ->(_text) { raise IOError, 'provider unavailable' }
    assert_raises(IOError) { Knowledge::Ingest.new(embedder: failing).call(tenant_id: 'a', title: 'x', body: 'x') }
    assert_equal 1, Knowledge::Document.count
    assert_raises(IOError) { Knowledge::Ingest.new(embedder: failing, version: 'v2').reembed(tenant_id: 'a', id: document.id) }
    assert_equal 2, Knowledge::Passage.count
    assert_raises(ActiveRecord::RecordNotFound) { Knowledge::Ingest.new.reembed(tenant_id: 'b', id: document.id) }
    Knowledge::Ingest.new(version: 'v2').reembed(tenant_id: 'a', id: document.id)
    assert_equal 4, Knowledge::Passage.count
    Knowledge::Ingest.new(version: 'v2').reembed(tenant_id: 'a', id: document.id)
    assert_equal 4, Knowledge::Passage.count
    assert_equal 2, Knowledge::Retrieve.new(version: 'v2').call(tenant_id: 'a', question: 'refund').size
    document.destroy!
    assert_empty Knowledge::Passage.all
    assert_empty Knowledge::Retrieve.new.call(tenant_id: 'a', question: 'refund')
  end

  def test_invalid_provider_vectors_cannot_commit
    invalid = ->(_text) { [Float::NAN] }
    assert_raises(ArgumentError) { Knowledge::Ingest.new(embedder: invalid).call(tenant_id: 'a', title: 'x', body: 'x') }
    assert_empty Knowledge::Document.all
  end
end
