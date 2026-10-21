# frozen_string_literal: true

module Knowledge
  class Retrieve
    def initialize(embedder: DemoEmbeddings.new, version: DemoEmbeddings::VERSION)
      @embedder = embedder
      @version = version
    end

    def call(tenant_id:, question:, limit: 3)
      Telemetry.measure('retrieve_sql') { retrieve(tenant_id, question, limit) }
    end

    private

    def retrieve(tenant_id, question, limit)
      vector = Vector.encode(@embedder.call(question))
      sql = ApplicationRecord.sanitize_sql_array([<<~SQL, { tenant: tenant_id, version: @version, vector: vector }])
        WITH scoped AS MATERIALIZED (
          SELECT d.id AS document_id, d.title, p.ordinal, p.body, p.document_revision,
                 p.embedding <=> :vector::vector AS distance
          FROM knowledge_passages p
          JOIN knowledge_documents d ON d.id = p.document_id
          WHERE d.tenant_id = :tenant AND p.version = :version
            AND p.document_revision = d.lock_version
        )
        SELECT * FROM scoped ORDER BY distance, document_id, ordinal
        LIMIT #{Integer(limit).clamp(1, 10)}
      SQL
      ApplicationRecord.connection.select_all(sql).to_a.map do |row|
        row.merge('citation' => "document:#{row.fetch('document_id')}#passage-#{row.fetch('ordinal')}")
      end
    end
  end
end
