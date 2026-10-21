# frozen_string_literal: true

require 'test_helper'

class QdrantTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    Knowledge::Document.delete_all
    @index = Knowledge::VectorIndex.new(alias_name: "test_#{SecureRandom.hex(6)}")
    @writer = Knowledge::SaveDocument.new
    @retrieve = Knowledge::Retrieve.new(index: @index)
  end

  test 'tenant filtering, embedding versions, retrieval relevance and deletion are authoritative' do
    refund = save('a', 'Return money within 30 days')
    save('a', 'Shipping delivery takes 2 days')
    secret = save('b', 'Secret refund policy')
    save('a', 'Refund under new version', version: 'demo-v2')
    Knowledge::Rebuild.new(index: @index).call
    hits = @retrieve.call(tenant: 'a', question: 'refund')
    assert_equal refund.body, hits.first.fetch(:text)
    answer = Knowledge::Answer.new(retrieve: @retrieve).call(tenant: 'a', question: 'refund')
    assert_includes answer[:answer], hits.first[:citation]
    assert_equal hits.pluck(:citation), answer[:citations]
    assert_equal "document:#{refund.id}@1", hits.first.fetch(:citation)
    assert_not(hits.any? { |hit| hit[:text] == secret.body })
    assert_equal ['Refund under new version'],
                 @retrieve.call(tenant: 'a', question: 'refund', version: 'demo-v2').pluck(:text)
    Knowledge::Gate.synchronize { refund.increment(:revision).update!(deleted: true) }
    assert_not(@retrieve.call(tenant: 'a', question: 'refund').any? { |hit| hit[:citation].include?(refund.id) })
    Knowledge::Rebuild.new(index: @index).call
    assert @index.snapshot(@index.current).find { |point| point['id'] == refund.id }.dig('payload', 'deleted')
  end

  test 'backfill catches concurrent writes and validation failure preserves the previous alias' do
    original = save('a', 'Refund old policy')
    old = Knowledge::Rebuild.new(index: @index).call
    current = Knowledge::Rebuild.new(index: @index).call(after_backfill: lambda {
      @writer.call(tenant: 'a', title: 'Policy', body: 'Refund updated policy', id: original.id)
      save('a', 'Shipping delivery added during backfill')
    })
    assert_not_equal old, current
    assert_equal 2, @index.snapshot(current).size
    assert_equal 'Refund updated policy', @retrieve.call(tenant: 'a', question: 'refund').first[:text]
    invalid = Class.new(Knowledge::VectorIndex) do
      def snapshot(_collection)
        []
      end
    end.new(alias_name: @index.instance_variable_get(:@alias_name))
    assert_raises(IOError) { Knowledge::Rebuild.new(index: invalid).call }
    assert_equal current, @index.current
    assert_equal 1, @index.snapshot(old).size
  end

  test 'provider failures preserve authoritative writes and a later rebuild recovers' do
    document = save('a', 'Refund policy')
    unavailable = Knowledge::VectorIndex.new(url: 'http://127.0.0.1:1')
    assert_raises(Errno::ECONNREFUSED) { Knowledge::Rebuild.new(index: unavailable).call }
    assert_equal document.body, document.reload.body
    broken_embedding = ->(_) { raise IOError, 'Embedding provider unavailable' }
    assert_raises(IOError) do
      Knowledge::SaveDocument.new(embeddings: broken_embedding).call(tenant: 'a', title: 'Bad', body: 'Bad')
    end
    assert_equal 1, Knowledge::Document.count
    Knowledge::Rebuild.new(index: @index).call
    assert_equal document.body, @retrieve.call(tenant: 'a', question: 'refund').sole[:text]
  end

  private

  def save(tenant, body, version: 'demo-v1')
    @writer.call(tenant: tenant, title: 'Policy', body: body, version: version)
  end
end
