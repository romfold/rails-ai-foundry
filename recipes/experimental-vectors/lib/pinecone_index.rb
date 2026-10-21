# frozen_string_literal: true

require_relative 'http'
require_relative 'scope'

module Knowledge
  class PineconeIndex
    def initialize(scope:, endpoint:, api_key:)
      raise ArgumentError, 'API key required' if api_key.to_s.empty?

      @scope = scope
      @http = Http.new(endpoint: endpoint, headers: { 'Api-Key' => api_key, 'X-Pinecone-API-Version' => '2025-04' })
    end

    def upsert(id:, vector:, revision:)
      @scope.revision!(revision)
      @http.call('post', '/vectors/upsert', namespace: @scope.namespace,
                                            vectors: [{ id: @scope.id!(id), values: @scope.vector!(vector),
                                                        metadata: { version: @scope.version, revision: revision } }])
    end

    def search(vector:)
      response = @http.call('post', '/query', namespace: @scope.namespace, vector: @scope.vector!(vector),
                                              topK: 5, includeMetadata: true,
                                              filter: { version: { '$eq' => @scope.version } })
      response.fetch('matches').map do |match|
        { 'id' => match.fetch('id'), 'revision' => match.fetch('metadata').fetch('revision') }
      end
    rescue KeyError, NoMethodError, TypeError
      raise ProviderError, 'Malformed Pinecone matches'
    end

    def delete(id:)
      @http.call('post', '/vectors/delete', namespace: @scope.namespace, ids: [@scope.id!(id)])
    end
  end
end
