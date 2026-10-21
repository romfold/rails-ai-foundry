# frozen_string_literal: true

module Knowledge
  class Document < ApplicationRecord
    self.table_name = 'knowledge_documents'
    validates :tenant_id, :title, :body, presence: true
  end
end
