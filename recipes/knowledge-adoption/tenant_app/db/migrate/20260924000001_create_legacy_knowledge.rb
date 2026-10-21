# frozen_string_literal: true

class CreateLegacyKnowledge < ActiveRecord::Migration[8.1]
  def change
    create_table :knowledge_collections do |t|
      t.string :tenant_id
      t.string :name, null: false
    end
    add_index :knowledge_collections, %i[id tenant_id], unique: true
    create_table :knowledge_documents do |t|
      t.bigint :collection_id, null: false
      t.string :title, null: false
      t.text :body, null: false
      t.integer :revision, null: false, default: 1
      t.timestamps null: false
    end
    add_foreign_key :knowledge_documents, :knowledge_collections, column: :collection_id
    add_index :knowledge_documents, :collection_id
  end
end
