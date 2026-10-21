# frozen_string_literal: true

class CreateKnowledge < ActiveRecord::Migration[8.1]
  def change
    enable_extension 'vector'
    documents
    deliveries
    vectors
  end

  private

  def documents
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

  def deliveries
    create_table :knowledge_deliveries, id: :uuid do |t|
      t.uuid :event_id, null: false
      t.string :target, null: false
      t.text :payload, null: false
      t.string :state, null: false, default: 'pending'
      t.string :lease_token
      t.datetime :lease_until
      t.datetime :available_at, null: false
      t.integer :attempts, null: false, default: 0
      t.string :error_code
      t.timestamps null: false
    end
    add_index :knowledge_deliveries, %i[event_id target], unique: true
    add_index :knowledge_deliveries, %i[target state available_at]
  end

  def vectors
    create_table :search_vectors do |t|
      t.uuid :document_id, null: false
      t.string :tenant_id, null: false
      t.integer :revision, null: false
      t.string :version, null: false
      t.column :embedding, 'vector(1536)', null: false
    end
    add_index :search_vectors, %i[document_id version], unique: true
    create_table :search_settings, id: false do |t|
      t.string :key, primary_key: true
      t.string :value, null: false
    end
  end
end
