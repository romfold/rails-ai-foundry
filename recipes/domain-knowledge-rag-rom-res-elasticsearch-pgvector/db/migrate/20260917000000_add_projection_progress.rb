# frozen_string_literal: true

class AddProjectionProgress < ActiveRecord::Migration[8.1]
  def change
    create_table :knowledge_projection_changes do |t|
      t.uuid :document_id, null: false
      t.integer :revision, null: false
      t.string :status, null: false
      t.datetime :created_at, null: false
    end
    runs
    entries
    read_indexes
  end

  private

  def runs
    create_table :search_rebuild_runs, id: :uuid do |t|
      t.string :destination, null: false
      t.string :candidate, null: false
      t.string :phase, null: false, default: 'queued'
      t.bigint :initial_fence, :cursor, null: false, default: 0
      t.uuid :upper_id, :page_key, :validation_key
      t.string :lease_token, :error_code, :prior_alias
      t.datetime :lease_until
      t.integer :attempts, null: false, default: 0
      t.boolean :cutover_intent, null: false, default: false
      t.timestamps null: false
    end
    add_index :search_rebuild_runs, :candidate, unique: true
    add_index :search_rebuild_runs, :destination, unique: true,
                                                  where: "phase NOT IN ('completed', 'cancelled')",
                                                  name: 'one_live_projection_rebuild'
  end

  def entries
    create_table :search_rebuild_entries do |t|
      t.uuid :run_id, :document_id, null: false
      t.integer :revision, null: false
      t.text :payload, null: false
    end
    add_index :search_rebuild_entries, %i[run_id document_id], unique: true
    add_foreign_key :search_rebuild_entries, :search_rebuild_runs, column: :run_id
  end

  def read_indexes
    add_index :search_vectors, %i[tenant_id version document_id]
    add_index :knowledge_documents, %i[tenant_id id]
    add_index :knowledge_deliveries, "(payload::jsonb ->> 'document_id'), target, created_at DESC",
              name: 'knowledge_delivery_document_status'
  end
end
