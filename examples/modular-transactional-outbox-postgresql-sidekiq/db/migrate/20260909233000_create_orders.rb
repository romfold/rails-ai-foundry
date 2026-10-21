# frozen_string_literal: true

class CreateOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :orders_orders do |t|
      t.string :tenant, null: false
      t.integer :cents, null: false
      t.string :state, null: false, default: 'placed'
    end
    add_check_constraint :orders_orders, 'cents > 0', name: 'positive_order'
    create_table :orders_outbox_entries do |t|
      t.jsonb :payload, null: false
      t.integer :attempts, null: false, default: 0
      t.datetime :next_attempt_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :completed_at
      t.datetime :poisoned_at
      t.string :last_error
    end
    add_index :orders_outbox_entries, :next_attempt_at, where: 'completed_at IS NULL AND poisoned_at IS NULL'
    create_table :orders_receipts do |t|
      t.references :outbox_entry, null: false, index: { unique: true },
                                  foreign_key: { to_table: :orders_outbox_entries }
    end
  end
end
