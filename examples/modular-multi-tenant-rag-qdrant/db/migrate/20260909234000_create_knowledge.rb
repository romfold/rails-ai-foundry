# frozen_string_literal: true

class CreateKnowledge < ActiveRecord::Migration[8.1]
  def change
    create_table :knowledge_documents, id: :uuid do |t|
      t.string :tenant, null: false
      t.string :title, null: false
      t.text :body, null: false
      t.string :embedding_version, null: false
      t.jsonb :embedding, null: false
      t.integer :revision, null: false, default: 1
      t.boolean :deleted, null: false, default: false
    end
    add_index :knowledge_documents, %i[tenant embedding_version]
    create_table :knowledge_gates do |t|
      t.string :name, null: false
    end
    add_index :knowledge_gates, :name, unique: true
  end
end
