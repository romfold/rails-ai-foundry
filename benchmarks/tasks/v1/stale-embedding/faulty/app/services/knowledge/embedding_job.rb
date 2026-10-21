# frozen_string_literal: true

module Knowledge
  class EmbeddingJob
    def call(document_id:, tenant_id:, version:, provider:)
      snapshot = Document.find_by(id: document_id, tenant_id: tenant_id, published: true)
      return :discarded unless snapshot

      vector = provider.call(snapshot.body)
      Document.transaction do
        current = Document.lock.find_by(id: document_id, tenant_id: tenant_id, published: true)
        return :discarded unless current && current.revision >= snapshot.revision

        Embedding.upsert({ document_id: current.id, tenant_id: tenant_id, revision: current.revision,
                           version: version, vector: JSON.generate(vector) }, unique_by: %i[document_id version])
      end
      :stored
    end
  end
end
