# frozen_string_literal: true

[
  { reference: 'INV-001', amount_cents: 1250, status: 'paid' },
  { reference: 'INV-002', amount_cents: 3400, status: 'open' }
].each do |attributes|
  Billing::Invoice.find_or_create_by!(reference: attributes[:reference]) do |invoice|
    invoice.assign_attributes(attributes)
  end
end
