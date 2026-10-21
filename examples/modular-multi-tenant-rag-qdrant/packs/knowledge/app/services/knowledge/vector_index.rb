# frozen_string_literal: true

require 'net/http'
require 'json'

module Knowledge
  class VectorIndex
    def initialize(url: ENV.fetch('QDRANT_URL', 'http://127.0.0.1:56333'), alias_name: 'knowledge_current')
      @url = url
      @alias_name = alias_name
    end

    def create(name)
      request(:put, "/collections/#{name}", vectors: { size: 3, distance: 'Cosine' })
    end

    def upsert(document, collection: @alias_name)
      request(:put, "/collections/#{collection}/points?wait=true",
              points: [{ id: document.id, vector: document.embedding, payload: document.payload }])
    end

    def search(vector, tenant:, version:)
      filter = { must: [{ key: 'tenant', match: { value: tenant } },
                        { key: 'embedding_version', match: { value: version } },
                        { key: 'deleted', match: { value: false } }] }
      request(:post, "/collections/#{@alias_name}/points/search",
              vector: vector, filter: filter, limit: 5, with_payload: true).fetch('result')
    end

    def snapshot(collection)
      points = []
      offset = nil
      loop do
        body = { limit: 100, with_payload: true, with_vector: true }
        body[:offset] = offset if offset
        result = request(:post, "/collections/#{collection}/points/scroll", body).fetch('result')
        points.concat(result.fetch('points'))
        offset = result['next_page_offset']
        break unless offset
      end
      points
    end

    def current
      request(:get, '/aliases').fetch('result').fetch('aliases')
                               .find { |entry| entry['alias_name'] == @alias_name }&.fetch('collection_name')
    end

    def cutover(collection)
      actions = []
      actions << { delete_alias: { alias_name: @alias_name } } if current
      actions << { create_alias: { alias_name: @alias_name, collection_name: collection } }
      request(:post, '/collections/aliases', actions: actions)
    end

    private

    def request(method, path, body = nil)
      uri = URI("#{@url}#{path}")
      request = Net::HTTP.const_get(method.to_s.capitalize).new(uri, 'Content-Type' => 'application/json')
      request.body = JSON.generate(body) if body
      response = Net::HTTP.start(uri.host, uri.port, open_timeout: 2, read_timeout: 5) { |http| http.request(request) }
      raise IOError, "Qdrant HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    end
  end
end
