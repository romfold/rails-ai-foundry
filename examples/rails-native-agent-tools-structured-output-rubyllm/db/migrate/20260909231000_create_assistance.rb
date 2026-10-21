# frozen_string_literal: true

class CreateAssistance < ActiveRecord::Migration[8.1]
  def change
    create_table :assistance_users do |t|
      t.string :tenant, null: false
      t.string :token, null: false
      t.boolean :can_close, null: false, default: false
      t.boolean :active, null: false, default: true
    end
    add_index :assistance_users, :token, unique: true
    create_table :assistance_tickets do |t|
      t.string :tenant, null: false
      t.string :subject, null: false
      t.string :status, null: false, default: 'open'
    end
    add_index :assistance_tickets, :tenant
    add_check_constraint :assistance_tickets, "status IN ('open', 'closed')", name: 'ticket_status'
  end
end
