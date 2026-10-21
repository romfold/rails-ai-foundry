# frozen_string_literal: true

module Catalog
  class Product < ApplicationRecord
    self.table_name = 'catalog_products'
    validates :name, presence: true

    def projection
      attributes.slice('name', 'revision', 'deleted')
    end
  end
end
