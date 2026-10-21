# frozen_string_literal: true

require 'test_helper'

class ProviderTransactionTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  def test_embedding_calls_happen_outside_transactions
    Knowledge::Document.delete_all
    observed = []
    embedder = lambda do |text|
      observed << ApplicationRecord.connection.transaction_open?
      Knowledge::DemoEmbeddings.new.call(text)
    end
    document = Knowledge::Ingest.new(embedder: embedder).call(tenant_id: 'a', title: 'Policy', body: 'refund')
    Knowledge::Ingest.new(embedder: embedder).reembed(tenant_id: 'a', id: document.id)
    Knowledge::NeighborRetrieve.new(embedder: embedder).call(tenant_id: 'a', question: 'refund')
    Knowledge::Retrieve.new(embedder: embedder).call(tenant_id: 'a', question: 'refund')
    assert_equal [false, false, false, false], observed
  ensure
    Knowledge::Document.delete_all
  end
end
