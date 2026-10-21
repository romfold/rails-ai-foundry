# frozen_string_literal: true

module Knowledge
  class SaveDocument
    def initialize(embeddings: DemoEmbeddings.new)
      @embeddings = embeddings
    end

    def call(tenant:, title:, body:, version: 'demo-v1', id: nil)
      embedding = @embeddings.call(body)
      Gate.synchronize do
        document = id ? Document.where(tenant: tenant).find(id) : Document.new(tenant: tenant)
        document.revision += 1 if document.persisted?
        document.assign_attributes(title: title, body: body, embedding_version: version,
                                   embedding: embedding)
        document.save!
        document
      end
    end
  end
end
