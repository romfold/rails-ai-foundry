# frozen_string_literal: true

class CreatePipeline < ActiveRecord::Migration[8.1]
  def change
    create_table :pipeline_cursors do |t|
      t.string :tenant, null: false
      t.string :stream_key, null: false
      t.integer :position, null: false, default: 0
      t.bigint :total, null: false, default: 0
    end
    add_index :pipeline_cursors, %i[tenant stream_key], unique: true
    create_table :pipeline_receipts do |t|
      t.string :event_id, null: false
      t.string :fingerprint, null: false
    end
    add_index :pipeline_receipts, :event_id, unique: true
    create_table :pipeline_rejections do |t|
      t.string :fingerprint, null: false
      t.text :payload, null: false
      t.string :reason, null: false
    end
    add_index :pipeline_rejections, :fingerprint, unique: true
  end
end
