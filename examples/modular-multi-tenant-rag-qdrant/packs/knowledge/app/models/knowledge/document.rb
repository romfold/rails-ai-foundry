# frozen_string_literal: true

module Knowledge
  class Document < ApplicationRecord
    self.table_name = 'knowledge_documents'
    before_validation { self.id ||= SecureRandom.uuid }
    validates :tenant, :title, :body, :embedding_version, presence: true
    validates :body, length: { maximum: 8000 }

    def payload
      attributes.slice('tenant', 'title', 'body', 'embedding_version', 'revision', 'deleted')
    end
  end
end
