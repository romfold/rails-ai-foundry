# frozen_string_literal: true

class CreateKnowledgeDocuments < ActiveRecord::Migration[8.1]
  def change
    enable_extension 'vector'
    create_table :knowledge_documents do |t|
      t.string :tenant_id, null: false
      t.string :title, null: false
      t.text :body, null: false
      t.timestamps
    end
    add_index :knowledge_documents, :tenant_id
    create_table :knowledge_passages do |t|
      t.references :document, null: false, foreign_key: { to_table: :knowledge_documents, on_delete: :cascade }
      t.string :version, null: false
      t.integer :ordinal, null: false
      t.text :body, null: false
    end
    add_column :knowledge_passages, :embedding, 'vector(1536)', null: false
    add_index :knowledge_passages, %i[document_id version ordinal], unique: true
  end
end
