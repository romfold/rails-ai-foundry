# frozen_string_literal: true

module Knowledge
  class Passage < ApplicationRecord
    self.table_name = 'knowledge_passages'

    has_neighbors :embedding, dimensions: 1536
    belongs_to :document, class_name: 'Knowledge::Document'
  end
end
