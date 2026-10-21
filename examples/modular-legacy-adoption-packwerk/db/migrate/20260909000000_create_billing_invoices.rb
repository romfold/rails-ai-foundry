# frozen_string_literal: true

class CreateBillingInvoices < ActiveRecord::Migration[8.1]
  def change
    create_table :billing_invoices do |table|
      table.string :reference, null: false
      table.integer :amount_cents, null: false
      table.string :status, null: false, default: 'open'
      table.timestamps
    end
    add_index :billing_invoices, :reference, unique: true
    add_check_constraint :billing_invoices, 'amount_cents >= 0', name: 'nonnegative_invoice_amount'
    add_check_constraint :billing_invoices, "status IN ('open', 'paid')", name: 'valid_invoice_status'
  end
end
