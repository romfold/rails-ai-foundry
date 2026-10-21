# frozen_string_literal: true

class CreateKnowledge < ActiveRecord::Migration[8.1]
  def change
    create_table :knowledge_documents, id: :uuid do |t|
      t.string :tenant_id, null: false
      t.string :title, null: false
      t.text :body, null: false
      t.string :status, null: false, default: 'draft'
      t.integer :revision, null: false, default: 1
      t.timestamps null: false
    end
    add_index :knowledge_documents, %i[tenant_id status]
    add_check_constraint :knowledge_documents, "status IN ('draft', 'published', 'withdrawn', 'deleted')"
    add_check_constraint :knowledge_documents, 'revision > 0'
  end
end
