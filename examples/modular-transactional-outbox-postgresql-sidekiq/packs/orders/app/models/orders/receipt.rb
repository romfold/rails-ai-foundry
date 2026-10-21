# frozen_string_literal: true

module Orders
  class Receipt < ApplicationRecord
    self.table_name = 'orders_receipts'
  end
end
