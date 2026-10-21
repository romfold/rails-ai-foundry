# frozen_string_literal: true

module Search
  class VectorIndex
    def initialize(url:)
      @url = url
    end

    def active_version
      database[:search_settings].where(key: 'embedding_version').get(:value) || 'demo-v1'
    end

    def activate(version)
      database[:search_settings].insert_conflict(target: :key, update: { value: version })
                                .insert(key: 'embedding_version', value: version)
    end

    def store(document, vector, version:)
      data = { document_id: document.fetch(:id), tenant_id: document.fetch(:tenant_id),
               revision: document.fetch(:revision), version: version, embedding: Sequel.cast(encode(vector), :vector) }
      rows.insert_conflict(target: %i[document_id version], update: data).insert(data)
    end

    def remove(id)
      rows.where(document_id: id).delete
    end

    def candidates(tenant_id:, vector:, version:, limit:, after: nil)
      raise ArgumentError, 'Candidate limit must be between 1 and 100' unless (1..100).cover?(limit)

      distance = Sequel.lit('embedding <=> ?::vector', encode(vector))
      query = rows.where(tenant_id: tenant_id, version: version)
                  .select(:document_id, :revision, distance.as(:distance)).from_self
      query = query.where(after_cursor(after)) if after
      query.order(:distance, :document_id).limit(limit).all
    end

    def validate_page!(documents, version:)
      expected = documents.select { |document| document[:status] == 'published' }
                          .to_h { |document| [document[:id], [document[:revision], document[:embedding_digest]]] }
      actual = vector_contents(documents.pluck(:id), version)
      raise 'Vector content mismatch' unless actual == expected
    end

    def count(version)
      rows.where(version: version).count
    end

    def delete_version(version)
      raise 'Cannot delete active embedding version' if version == active_version

      rows.where(version: version).delete
    end

    def disconnect
      @rom&.disconnect
    end

    private

    def vector_contents(ids, version)
      selected = rows.where(version: version, document_id: ids)
                     .select(:document_id, :revision, Sequel.cast(:embedding, :text).as(:vector)).all
      report_page(selected)
      selected.to_h do |row|
        [row[:document_id], [row[:revision], Digest::SHA256.hexdigest(JSON.parse(row[:vector]).pack('e*'))]]
      end
    end

    def report_page(selected)
      bytes = selected.sum { |row| JSON.generate(row).bytesize }
      ActiveSupport::Notifications.instrument('vector_page.knowledge', rows: selected.size, bytes: bytes)
    end

    def after_cursor(cursor)
      Sequel.|(Sequel[:distance] > cursor.fetch(:distance),
               Sequel.&({ distance: cursor.fetch(:distance) }, Sequel[:document_id] > cursor.fetch(:document_id)))
    end

    def database
      @rom ||= ROM.container(:sql, @url, after_connect: lambda { |connection|
        connection.exec("SET statement_timeout = '2s'")
        connection.exec("SET lock_timeout = '2s'")
      })
      @rom.gateways[:default].connection
    end

    def rows
      database[:search_vectors]
    end

    def finite?(vector)
      vector.all? { |value| value.is_a?(Numeric) && value.finite? }
    end

    def encode(vector)
      valid = vector.is_a?(Array) && vector.size == 1536 &&
              finite?(vector) && vector.any? { |value| !value.zero? }
      raise ArgumentError, 'Expected a finite nonzero 1536-dimensional vector' unless valid

      JSON.generate(vector)
    end
  end
end
