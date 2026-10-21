# frozen_string_literal: true

module Billing
  module Invoices
    def self.total_paid_cents
      Invoice.where(status: 'paid').sum(:amount_cents)
    end
  end
end
