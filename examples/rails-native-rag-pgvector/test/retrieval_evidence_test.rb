# frozen_string_literal: true

require 'test_helper'

class RetrievalEvidenceTest < ActiveSupport::TestCase
  def test_bounded_hnsw_recall_against_exact_sql_and_actual_index_plan
    vectors = seed_corpus
    connection = ApplicationRecord.connection
    connection.execute('ANALYZE knowledge_documents')
    connection.execute('ANALYZE knowledge_passages')
    connection.execute('SET LOCAL enable_seqscan = off')
    connection.execute('SET LOCAL enable_sort = off')
    connection.execute('SET LOCAL hnsw.ef_search = 64')
    connection.execute("SET LOCAL hnsw.iterative_scan = 'strict_order'")
    connection.execute('SET LOCAL hnsw.max_scan_tuples = 1000')
    connection.execute("SET LOCAL statement_timeout = '2s'")
    recalls = vectors.first(5).map { |vector| compare_readers(vector) }
    plan = JSON.parse(connection.exec_query("EXPLAIN (FORMAT JSON) #{@query.fetch(:sql)}",
                                            'ANN evidence', @query.fetch(:binds)).rows.first.first)
    indexes = JSON.generate(plan).scan(/"Index Name":"([^"]+)"/).flatten
    assert_includes indexes, 'knowledge_passages_embedding_hnsw'
    assert_operator recalls.sum.fdiv(recalls.size), :>=, 0.8
    puts JSON.generate(corpus_size: 240, dimensions: 1536, seed: 41, queries: 5, k: 5,
                       recall_at_k: recalls.sum.fdiv(recalls.size), hnsw_ef_search: 64,
                       iterative_scan: 'strict_order', max_scan_tuples: 1000, statement_timeout_ms: 2000,
                       index_plan_verified: true, force_index_order: true, provider: 'deterministic offline vectors')
  end

  private

  def seed_corpus
    random = Random.new(41)
    vectors = []
    240.times do |index|
      vector = Array.new(12) { random.rand } + Array.new(1524, 0.0)
      tenant = index.even? ? 'a' : 'b'
      document = Knowledge::Document.create!(tenant_id: tenant, title: "Document #{index}", body: 'Fixed corpus')
      Knowledge::Passage.create!(document_id: document.id, version: 'evidence-v1', ordinal: 0,
                                 body: 'Fixed corpus', embedding: vector, document_revision: 0)
      vectors << vector if tenant == 'a'
    end
    vectors
  end

  def compare_readers(vector)
    embedder = ->(*) { vector }
    exact = Knowledge::Retrieve.new(embedder: embedder, version: 'evidence-v1')
                               .call(tenant_id: 'a', question: 'fixed vector', limit: 5)
    subscription = ActiveSupport::Notifications.subscribe('sql.active_record') do |*args|
      payload = args.last
      @query = payload.slice(:sql, :binds) if payload[:sql].include?(' AS neighbor_distance')
    end
    approximate = Knowledge::NeighborRetrieve.new(embedder: embedder, version: 'evidence-v1')
                                             .call(tenant_id: 'a', question: 'fixed vector', limit: 5)
    ids = approximate.pluck('document_id')
    assert_equal 5, ids.size
    assert_equal ['a'], Knowledge::Document.where(id: ids).distinct.pluck(:tenant_id)
    (ids & exact.pluck('document_id')).size.fdiv(5)
  ensure
    ActiveSupport::Notifications.unsubscribe(subscription) if subscription
  end
end
