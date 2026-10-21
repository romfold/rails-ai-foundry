# frozen_string_literal: true

module Knowledge
  class NeighborRetrieve
    def initialize(embedder: DemoEmbeddings.new, version: DemoEmbeddings::VERSION)
      @embedder = embedder
      @version = version
    end

    def call(tenant_id:, question:, limit: 3)
      Telemetry.measure('retrieve_neighbor') do
        vector = @embedder.call(question)
        Vector.encode(vector)
        relation(tenant_id, vector).limit(Integer(limit).clamp(1, 10)).map do |passage|
          { 'document_id' => passage.document_id, 'title' => passage['title'], 'ordinal' => passage.ordinal,
            'body' => passage.body, 'distance' => passage.neighbor_distance,
            'document_revision' => passage.document_revision,
            'citation' => "document:#{passage.document_id}#passage-#{passage.ordinal}" }
        end
      end
    end

    private

    def relation(tenant_id, vector)
      Passage.joins(:document).where(knowledge_documents: { tenant_id: tenant_id }, version: @version)
             .where('knowledge_passages.document_revision = knowledge_documents.lock_version')
             .select('knowledge_passages.id, document_id, document_revision, ordinal, ' \
                     'knowledge_passages.body, knowledge_documents.title')
             .nearest_neighbors(:embedding, vector, distance: 'cosine')
    end
  end
end
