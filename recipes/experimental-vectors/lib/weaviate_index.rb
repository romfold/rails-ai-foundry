# frozen_string_literal: true

require_relative 'http'
require_relative 'scope'

module Knowledge
  class WeaviateIndex
    def initialize(scope:, endpoint:)
      @scope = scope
      @http = Http.new(endpoint: endpoint)
      @collection = "Knowledge#{Digest::SHA256.hexdigest(scope.generation)[0, 16]}"
    end

    def prepare
      @http.call('post', '/v1/schema', class: @collection, vectorizer: 'none',
                                       multiTenancyConfig: { enabled: true },
                                       properties: [{ name: 'version', dataType: ['text'], tokenization: 'field' },
                                                    { name: 'revision', dataType: ['int'] }])
    end

    def add_tenant
      @http.call('post', "/v1/schema/#{@collection}/tenants", [{ name: @scope.namespace }])
    end

    def upsert(id:, vector:, revision:)
      @scope.revision!(revision)
      body = { class: @collection, id: @scope.id!(id), tenant: @scope.namespace,
               properties: { version: @scope.version, revision: revision }, vector: @scope.vector!(vector) }
      response = @http.call('post', '/v1/batch/objects', objects: [body])
      unless response.is_a?(Array) && response.one? && response.first.dig('result', 'status') == 'SUCCESS'
        raise ProviderError, 'Weaviate batch object failed'
      end

      response
    end

    def search(vector:)
      vector = JSON.generate(@scope.vector!(vector))
      query = "{ Get { #{@collection}(tenant: #{JSON.generate(@scope.namespace)}, limit: 5, " \
              "nearVector: {vector: #{vector}}, where: {path: [\"version\"], operator: Equal, " \
              "valueText: #{JSON.generate(@scope.version)}}) { revision _additional { id } } } }"
      response = @http.call('post', '/v1/graphql', query: query)
      raise ProviderError, 'Weaviate query failed' if response.key?('errors')

      matches(response).map do |match|
        { 'id' => match.fetch('_additional').fetch('id'), 'revision' => match.fetch('revision') }
      end
    rescue KeyError, NoMethodError, TypeError
      raise ProviderError, 'Malformed Weaviate matches'
    end

    def matches(response)
      response.fetch('data').fetch('Get').fetch(@collection)
    end
    private :matches

    def delete(id:)
      @http.call('delete', "/v1/objects/#{@collection}/#{@scope.id!(id)}?tenant=#{@scope.namespace}")
    end
  end
end
