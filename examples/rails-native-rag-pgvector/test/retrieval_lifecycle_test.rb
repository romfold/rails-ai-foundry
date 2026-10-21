# frozen_string_literal: true

require 'test_helper'

class RetrievalLifecycleTest < ActiveSupport::TestCase
  def test_ingestion_keys_are_idempotent_tenant_scoped_and_content_bound
    ingest = Knowledge::Ingest.new
    args = { tenant_id: 'a', source_key: 'policy', title: 'Refund', body: 'return money' }
    first = ingest.call(**args)
    assert_equal first.id, ingest.call(**args).id
    assert_equal 1, Knowledge::Passage.count
    assert_raises(Knowledge::Ingest::SourceConflict) { ingest.call(**args, body: 'different') }
    assert_equal 'return money', first.reload.body
    refute_equal first.id, ingest.call(**args, tenant_id: 'b').id
  end

  def test_stale_provider_results_preserve_passages_and_are_excluded_from_both_readers
    document = Knowledge::Ingest.new.call(tenant_id: 'a', title: 'Refund', body: 'return money')
    previous = Knowledge::Passage.pluck(:id, :body)
    changing = lambda do |text|
      document.update!(body: 'shipping only')
      Knowledge::DemoEmbeddings.new.call(text)
    end
    assert_raises(Knowledge::Ingest::StaleSource) do
      Knowledge::Ingest.new(embedder: changing).reembed(tenant_id: 'a', id: document.id)
    end
    assert_equal previous, Knowledge::Passage.pluck(:id, :body)
    readers.each { |reader| assert_empty reader.call(tenant_id: 'a', question: 'refund') }
    Knowledge::Ingest.new.reembed(tenant_id: 'a', id: document.id)
    readers.each do |reader|
      result = reader.call(tenant_id: 'a', question: 'shipping').first
      assert_equal 'shipping only', result.fetch('body')
      assert_equal document.lock_version, result.fetch('document_revision')
    end
  end

  def test_shared_read_contract_filters_tenants_versions_deletions_and_cites_sources
    allowed = Knowledge::Ingest.new.call(tenant_id: 'a', title: 'Allowed', body: 'refund')
    Knowledge::Ingest.new.call(tenant_id: 'b', title: 'Private', body: 'refund return money')
    readers.each do |reader|
      row = reader.call(tenant_id: 'a', question: 'refund').first
      assert_equal allowed.id, row.fetch('document_id')
      assert_equal "document:#{allowed.id}#passage-0", row.fetch('citation')
      assert_empty reader.call(tenant_id: 'unknown', question: 'refund')
    end
    [Knowledge::Retrieve, Knowledge::NeighborRetrieve].each do |type|
      assert_empty type.new(version: 'not-indexed').call(tenant_id: 'a', question: 'refund')
      assert_raises(IOError) do
        type.new(embedder: ->(*) { raise IOError }).call(tenant_id: 'a', question: 'refund')
      end
    end
    allowed.destroy!
    readers.each { |reader| assert_empty reader.call(tenant_id: 'a', question: 'refund') }
  end

  def test_notifications_do_not_expose_provider_errors_or_content
    events = []
    subscription = ActiveSupport::Notifications.subscribe(/\Aknowledge\./) do |*args|
      events << ActiveSupport::Notifications::Event.new(*args)
    end
    Knowledge::Ingest.new.call(tenant_id: 'sensitive-tenant', title: 'Private', body: 'secret prompt')
    assert_raises(IOError) do
      Knowledge::Retrieve.new(embedder: ->(*) { raise IOError, 'provider echoed secret prompt' })
                         .call(tenant_id: 'sensitive-tenant', question: 'secret prompt')
    end
    assert_includes events.map(&:name), 'knowledge.indexed'
    assert_includes events.map { |event| event.payload[:status] }, 'failed'
    assert(events.all? { |event| (event.payload.keys - %i[duration_ms status index_lag_ms]).empty? })
    refute_includes JSON.generate(events.map(&:payload)), 'secret'
  ensure
    ActiveSupport::Notifications.unsubscribe(subscription) if subscription
  end

  private

  def readers
    [Knowledge::Retrieve.new, Knowledge::NeighborRetrieve.new]
  end
end
