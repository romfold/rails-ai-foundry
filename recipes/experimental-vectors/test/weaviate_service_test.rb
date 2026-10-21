# frozen_string_literal: true

abort 'Activate the disposable service lane with WEAVIATE_ACCEPTANCE=1' unless ENV['WEAVIATE_ACCEPTANCE'] == '1'
require 'minitest/autorun'
require 'securerandom'
require 'webmock/minitest'
require_relative '../lib/weaviate_index'
WebMock.disable_net_connect!(allow: '127.0.0.1:58080')

class WeaviateServiceTest < Minitest::Test
  def test_real_tenant_version_update_and_delete
    generation = "test_#{SecureRandom.hex(8)}"
    a = build('tenant_a', 'v1', generation)
    b = build('tenant_b', 'v1', generation)
    v2 = build('tenant_a', 'v2', generation)
    a.prepare
    a.add_tenant
    b.add_tenant
    v2.add_tenant
    id = SecureRandom.uuid
    a.upsert(id: id, vector: [1, 0, 0], revision: 1)
    b.upsert(id: id, vector: [0, 1, 0], revision: 9)
    assert_equal [{ 'id' => id, 'revision' => 1 }], a.search(vector: [1, 0, 0])
    assert_equal [{ 'id' => id, 'revision' => 9 }], b.search(vector: [1, 0, 0])
    assert_empty v2.search(vector: [1, 0, 0])
    verify_version_deletion(a, v2, id)
    a.upsert(id: id, vector: [1, 0, 0], revision: 2)
    assert_equal 2, a.search(vector: [1, 0, 0]).first.fetch('revision')
    a.delete(id: id)
    assert_empty a.search(vector: [1, 0, 0])
    assert_equal 9, b.search(vector: [1, 0, 0]).first.fetch('revision')
  ensure
    if generation
      collection = "Knowledge#{Digest::SHA256.hexdigest(generation)[0, 16]}"
      Knowledge::Http.new(endpoint: 'http://127.0.0.1:58080').call('delete', "/v1/schema/#{collection}")
    end
  end

  private

  def verify_version_deletion(original, version_two, id)
    version_two.upsert(id: id, vector: [1, 0, 0], revision: 3)
    version_two.delete(id: id)
    assert_equal 1, original.search(vector: [1, 0, 0]).first.fetch('revision')
  end

  def build(tenant, version, generation)
    scope = Knowledge::Scope.new(tenant: tenant, version: version, generation: generation)
    Knowledge::WeaviateIndex.new(scope: scope, endpoint: 'http://127.0.0.1:58080')
  end
end
