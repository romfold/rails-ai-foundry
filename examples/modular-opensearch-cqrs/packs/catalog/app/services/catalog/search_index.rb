# frozen_string_literal: true

module Catalog
  class SearchIndex
    attr_reader :client, :name

    def initialize(url: ENV.fetch('OPENSEARCH_URL', 'http://127.0.0.1:59200'), name: "foundry_catalog_#{Rails.env}")
      @client = OpenSearch::Client.new(url: url, transport_options: { request: { timeout: 3, open_timeout: 2 } })
      @name = name
    end

    def create(index)
      client.indices.create(index: index, body: {
                              settings: { number_of_shards: 1, number_of_replicas: 0 },
                              mappings: { properties: { name: { type: 'text' }, revision: { type: 'long' },
                                                        deleted: { type: 'boolean' } } }
                            })
    end

    def publish(payload, index: name)
      product = Product.find(payload.fetch('product_id'))
      client.index(index: index, id: product.id, version: product.revision, version_type: 'external_gte',
                   body: product.projection, refresh: true)
    rescue OpenSearch::Transport::Transport::Errors::Conflict
      # A concurrent newer revision already won; never overwrite it with an older snapshot.
      nil
    end

    def search(query)
      client.search(index: name, body: { query: { bool: { must: [{ match: { name: query } }],
                                                          filter: [{ term: { deleted: false } }] } } })
            .dig('hits', 'hits').map { |hit| hit.fetch('_source').merge('id' => hit.fetch('_id')) }
    end

    def targets
      client.indices.get_alias(name: name).keys
    rescue OpenSearch::Transport::Transport::Errors::NotFound
      []
    end

    def cutover(index)
      actions = targets.map { |old| { remove: { index: old, alias: name } } }
      client.indices.update_aliases(body: { actions: actions + [{ add: { index: index, alias: name } }] })
    end
  end
end
