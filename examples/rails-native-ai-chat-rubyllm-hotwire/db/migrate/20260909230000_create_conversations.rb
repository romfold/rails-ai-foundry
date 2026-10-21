# frozen_string_literal: true

class CreateConversations < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations_chats do |t|
      t.string :tenant, null: false
      t.timestamps
    end
    create_table :conversations_messages do |t|
      t.references :chat, null: false, foreign_key: { to_table: :conversations_chats }
      t.text :question, null: false
      t.text :answer, null: false, default: ''
      t.string :state, null: false, default: 'pending'
      t.timestamps
    end
    add_index :conversations_chats, :tenant
    add_index :conversations_messages, :chat_id, unique: true, where: "state = 'pending'", name: 'one_pending_reply'
    add_check_constraint :conversations_messages, "state IN ('pending', 'complete', 'failed')", name: 'reply_state'
  end
end
