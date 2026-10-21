# frozen_string_literal: true

class CreateCatalog < ActiveRecord::Migration[8.1]
  def change
    create_table :catalog_products do |t|
      t.string :name, null: false
      t.integer :revision, null: false, default: 1
      t.boolean :deleted, null: false, default: false
      t.timestamps
    end
    create_outbox
    create_gate
  end

  private

  def create_outbox
    create_table :catalog_outbox_entries do |t|
      t.jsonb :payload, null: false
      t.integer :attempts, null: false, default: 0
      t.datetime :available_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :delivered_at
      t.datetime :poisoned_at
      t.string :last_error
      t.timestamps
    end
    add_index :catalog_outbox_entries, :available_at, where: 'delivered_at IS NULL AND poisoned_at IS NULL'
  end

  def create_gate
    create_table :catalog_rebuild_gates do |t|
      t.string :name, null: false
    end
    add_index :catalog_rebuild_gates, :name, unique: true
  end
end
