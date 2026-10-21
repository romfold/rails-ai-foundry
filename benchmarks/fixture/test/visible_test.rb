# frozen_string_literal: true

require_relative 'test_helper'

class VisibleTest < BenchmarkTest
  include Rack::Test::Methods

  def app
    Rails.application
  end

  def test_existing_endpoint
    expected = document
    get '/documents', {}, { 'HTTP_AUTHORIZATION' => 'tenant-a-token' }
    assert_equal 200, last_response.status
    assert_equal([expected.id], JSON.parse(last_response.body).map { |row| row.fetch('id') })
  end

  def test_normal_embedding
    expected = document
    result = Knowledge::EmbeddingJob.new.call(document_id: expected.id, tenant_id: 'a', version: 'v1',
                                              provider: ->(_body) { [0.25, 0.5] })
    assert_equal :stored, result
    assert_equal 1, Knowledge::Embedding.count
  end
end
