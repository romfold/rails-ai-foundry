# frozen_string_literal: true

module Billing
  class Invoice < ApplicationRecord
    self.table_name = 'billing_invoices'
    validates :reference, presence: true, uniqueness: true
    validates :amount_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
    validates :status, inclusion: { in: %w[open paid] }
  end
end
