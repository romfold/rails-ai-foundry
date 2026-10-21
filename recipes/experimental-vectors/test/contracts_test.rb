# frozen_string_literal: true

require 'minitest/autorun'
require 'webmock/minitest'
require_relative '../lib/pinecone_index'
require_relative '../lib/weaviate_index'
require_relative '../lib/citations'
WebMock.disable_net_connect!

class ContractsTest < Minitest::Test
  ID = '11111111-1111-4111-8111-111111111111'

  def setup
    @scope = Knowledge::Scope.new(tenant: 'tenant_a', version: 'v1', generation: 'g1')
    @index = Knowledge::PineconeIndex.new(scope: @scope, endpoint: 'https://index.example', api_key: 'test-key')
  end

  def test_pinecone_scope_applies_to_every_operation
    %w[/vectors/upsert /vectors/delete /query].each do |path|
      stub_request(:post, "https://index.example#{path}").with do |request|
        body = JSON.parse(request.body)
        body['namespace'] == @scope.namespace && request.headers['X-Pinecone-Api-Version'] == '2025-04'
      end.to_return(body: JSON.generate(matches: [{ id: ID, metadata: { revision: 2 } }]))
    end
    @index.upsert(id: ID, vector: [1, 0, 0], revision: 2)
    assert_equal [{ 'id' => ID, 'revision' => 2 }], @index.search(vector: [1, 0, 0])
    @index.delete(id: ID)
    refute_equal @scope.namespace, Knowledge::Scope.new(tenant: 'tenant_b', version: 'v1', generation: 'g1').namespace
    refute_equal @scope.namespace, Knowledge::Scope.new(tenant: 'tenant_a', version: 'v2', generation: 'g1').namespace
    assert_requested :post, 'https://index.example/query', body: /"filter":\{"version":\{"\$eq":"v1"\}\}/
  end

  def test_provider_failures_are_explicit_and_not_retried
    request = stub_request(:post, 'https://index.example/query').to_return(status: 503)
    assert_raises(Knowledge::ProviderError) { @index.search(vector: [1, 0, 0]) }
    assert_requested request, times: 1
    stub_request(:post, 'https://index.example/query').to_return(body: '{invalid')
    assert_raises(Knowledge::ProviderError) { @index.search(vector: [1, 0, 0]) }
    stub_request(:post, 'https://index.example/query').to_return(body: '{}')
    assert_raises(Knowledge::ProviderError) { @index.search(vector: [1, 0, 0]) }
  end

  def test_rejects_invalid_scope_vector_and_document_identifier_before_http
    assert_raises(ArgumentError) { Knowledge::Scope.new(tenant: '', version: 'v1', generation: 'g1') }
    assert_raises(ArgumentError) { @index.search(vector: [Float::NAN, 0, 0]) }
    assert_raises(ArgumentError) { @index.delete(id: '../other') }
    assert_raises(ArgumentError) { Knowledge::Http.new(endpoint: 'http://external.example') }
  end

  def test_citations_recheck_tenant_version_deletion_and_revision
    index = Object.new
    index.define_singleton_method(:search) { |**| [{ 'id' => ID, 'revision' => 2 }] }
    record = { id: ID, tenant: 'tenant_a', version: 'v1', revision: 2, deleted: false, text: 'Approved evidence' }
    documents = lambda do |tenant:, id:|
      assert_equal 'tenant_a', tenant
      assert_equal ID, id
      record
    end
    citations = Knowledge::Citations.new(scope: @scope, index: index, documents: documents)
    assert_equal(['Approved evidence'], citations.call(vector: [1, 0, 0]).map { |item| item[:text] })
    [{ deleted: true }, { revision: 3 }, { tenant: 'tenant_b' }, { version: 'v2' }].each do |change|
      original = record.dup
      record.merge!(change)
      assert_empty citations.call(vector: [1, 0, 0])
      record.replace(original)
    end
  end

  def test_weaviate_batch_error_and_graphql_errors_fail
    index = Knowledge::WeaviateIndex.new(scope: @scope, endpoint: 'http://127.0.0.1:58080')
    stub_request(:post, 'http://127.0.0.1:58080/v1/batch/objects').to_return(body: '[{"result":{"status":"FAILED"}}]')
    assert_raises(Knowledge::ProviderError) { index.upsert(id: ID, vector: [1, 0, 0], revision: 1) }
    stub_request(:post, 'http://127.0.0.1:58080/v1/graphql').to_return(body: '{"errors":[{"message":"unavailable"}]}')
    assert_raises(Knowledge::ProviderError) { index.search(vector: [1, 0, 0]) }
  end
end
