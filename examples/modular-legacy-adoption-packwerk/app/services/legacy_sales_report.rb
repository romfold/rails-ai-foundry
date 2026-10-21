# frozen_string_literal: true

class LegacySalesReport
  def self.total_paid_cents
    Billing::Invoice.where(status: 'paid').sum(:amount_cents)
  end
end
