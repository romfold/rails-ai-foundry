# frozen_string_literal: true

module Search
  class ElasticIndex
    attr_reader :name, :client

    def initialize(url:, name:)
      @client = Elasticsearch::Client.new(url: url, request_timeout: 2)
      @name = name
    end

    def create(index, alias_name: nil)
      client.indices.create(index: index, body: {
                              aliases: alias_name ? { alias_name => {} } : {},
                              settings: { number_of_shards: 1, number_of_replicas: 0 },
                              mappings: { dynamic: 'strict', properties: {
                                tenant_id: { type: 'keyword' }, status: { type: 'keyword' },
                                revision: { type: 'integer' }, title: { type: 'text' }, body: { type: 'text' }
                              } }
                            })
    end

    def setup
      return if client.indices.exists_alias(name: name)

      create("#{name}_initial", alias_name: name)
    rescue Elastic::Transport::Transport::Errors::BadRequest
      # Index creation and its bootstrap alias are one cluster-state action. A delayed
      # repeat cannot re-add an old alias after a rebuild because the reserved index exists.
      raise unless client.indices.exists_alias(name: name)
    end

    def upsert(document, index: name)
      client.index(index: index, id: document.fetch(:id), version: document.fetch(:revision),
                   version_type: 'external_gte', body: projection(document), refresh: true)
    rescue Elastic::Transport::Transport::Errors::Conflict
      # A newer revision (including its tombstone) is already indexed.
      false
    end

    def query(tenant_id:, query:)
      response = client.search(index: name, body: { size: 20, query: { bool: {
                                 filter: [{ term: { tenant_id: tenant_id } }, { term: { status: 'published' } }],
                                 must: [{ multi_match: { query: query, fields: %w[title body] } }]
                               } } })
      response.fetch('hits').fetch('hits').map { |hit| [hit.fetch('_id'), hit.fetch('_source').fetch('revision')] }
    end

    def selected
      client.indices.get_alias(name: name).keys
    end

    def exists?(index)
      client.indices.exists(index: index)
    end

    def bulk(documents, index:)
      body = bulk_body(documents, index)
      bytes = bulk_bytes(body)
      if bytes > Rails.configuration.x.knowledge_limits.fetch(:bulk_bytes)
        raise ArgumentError,
              'Bulk payload exceeds limit'
      end
      return if body.empty?

      ActiveSupport::Notifications.instrument('rebuild_batch.knowledge', rows: documents.size, bytes: bytes)
      result = client.bulk(body: body, refresh: true)
      raise 'Partial bulk failure' if bulk_failed?(result)
    end

    def validate_page!(documents, index:)
      return if documents.empty?

      actual = client.mget(index: index, body: { ids: documents.pluck(:id) }).fetch('docs')
      valid = actual.zip(documents).all? do |hit, document|
        hit['found'] && hit['_source'] == projection(document).stringify_keys
      end
      raise 'Search content mismatch' unless valid
    end

    def count(index)
      client.count(index: index).fetch('count')
    end

    def guarded_cutover(index, previous:)
      result = client.indices.update_aliases(body: { actions: [
                                               { remove: { index: previous, alias: name, must_exist: true } },
                                               { add: { index: index, alias: name } }
                                             ] })
      raise 'Unconfirmed alias action' unless result['acknowledged'] && !result['errors']
    end

    def delete(index)
      raise 'Cannot delete active search index' if selected.include?(index)

      client.indices.delete(index: index)
    end

    private

    def bulk_bytes(body)
      body.sum { |item| JSON.generate(item).bytesize + 1 }
    end

    def bulk_body(documents, index)
      documents.flat_map do |document|
        [{ index: { _index: index, _id: document.fetch(:id), version: document.fetch(:revision),
                    version_type: 'external_gte' } }, projection(document)]
      end
    end

    def bulk_failed?(result)
      result.fetch('items').any? do |item|
        status = item.fetch('index').fetch('status')
        status >= 300 && status != 409
      end
    end

    def projection(document)
      document.slice(:tenant_id, :status, :revision, :title, :body)
    end
  end
end
