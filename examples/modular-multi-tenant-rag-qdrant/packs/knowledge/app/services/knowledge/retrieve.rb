# frozen_string_literal: true

module Knowledge
  class Retrieve
    def initialize(index: VectorIndex.new, embeddings: DemoEmbeddings.new)
      @index = index
      @embeddings = embeddings
    end

    def call(tenant:, question:, version: 'demo-v1')
      hits = @index.search(@embeddings.call(question), tenant: tenant, version: version)
      records = Document.where(tenant: tenant, embedding_version: version, deleted: false,
                               id: hits.map { |hit| hit.fetch('id') }).index_by(&:id)
      hits.filter_map do |hit|
        document = records[hit.fetch('id')]
        next unless document && document.revision == hit.fetch('payload').fetch('revision')

        evidence(document, hit)
      end
    end

    private

    def evidence(document, hit)
      { text: document.body, citation: "document:#{document.id}@#{document.revision}", score: hit.fetch('score') }
    end
  end
end
