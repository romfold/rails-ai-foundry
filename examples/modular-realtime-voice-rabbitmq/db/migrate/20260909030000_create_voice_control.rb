# frozen_string_literal: true

class CreateVoiceControl < ActiveRecord::Migration[8.1]
  def change
    create_table :voice_sessions do |t|
      t.string :tenant_id, null: false
      t.integer :epoch, null: false, default: 0
      t.integer :delivered_epoch, null: false, default: 0
      t.integer :last_sequence, null: false, default: -1
      t.string :state, null: false, default: 'idle'
      t.timestamps
    end
    create_controls
    create_receipts
    create_frames
  end

  private

  def create_controls
    create_table :voice_controls do |t|
      t.string :event_id, null: false
      t.jsonb :payload, null: false
      t.integer :attempts, null: false, default: 0
      t.datetime :available_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :delivered_at
      t.datetime :poisoned_at
    end
    add_index :voice_controls, :event_id, unique: true
  end

  def create_receipts
    create_table :voice_receipts do |t|
      t.string :event_id, null: false
      t.string :fingerprint, null: false
    end
    add_index :voice_receipts, :event_id, unique: true
  end

  def create_frames
    create_table :voice_frames do |t|
      t.references :session, null: false, foreign_key: { to_table: :voice_sessions, on_delete: :cascade }
      t.integer :epoch, null: false
      t.integer :sequence, null: false
      t.binary :data, null: false
    end
    add_index :voice_frames, %i[session_id epoch sequence], unique: true
    add_check_constraint :voice_frames, 'octet_length(data) <= 4096', name: 'bounded_voice_frame'
  end
end
