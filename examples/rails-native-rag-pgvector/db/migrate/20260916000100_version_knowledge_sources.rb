# frozen_string_literal: true

class VersionKnowledgeSources < ActiveRecord::Migration[8.1]
  def change
    add_column :knowledge_documents, :source_key, :string
    add_column :knowledge_documents, :lock_version, :integer, null: false, default: 0
    add_index :knowledge_documents, %i[tenant_id source_key], unique: true
    add_column :knowledge_passages, :document_revision, :integer, null: false, default: 0
    add_index :knowledge_passages, :embedding, using: :hnsw, opclass: :vector_cosine_ops,
                                               name: 'knowledge_passages_embedding_hnsw'
  end
end
