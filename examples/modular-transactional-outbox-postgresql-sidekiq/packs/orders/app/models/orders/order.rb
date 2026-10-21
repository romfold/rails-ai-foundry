# frozen_string_literal: true

module Orders
  class Order < ApplicationRecord
    self.table_name = 'orders_orders'
    validates :tenant, presence: true
    validates :cents, numericality: { only_integer: true, greater_than: 0 }
  end
end
