# frozen_string_literal: true

module Knowledge
  class Document < ApplicationRecord
    self.table_name = 'knowledge_documents'
    belongs_to :collection
    validates :title, :body, presence: true
  end
end
