# frozen_string_literal: true

require 'dry/operation'

module Catalog
  class SaveProduct < Dry::Operation
    skip_prepending

    def call(name:, id: nil, deleted: false)
      result = nil
      ApplicationRecord.transaction(requires_new: true) do
        RebuildGate.synchronize do
          result = steps do
            product = step persist(name, id, deleted)
            step enqueue(product)
            product
          end
        end
        raise ActiveRecord::Rollback if result.failure?
      end
      result
    end

    private

    def persist(name, id, deleted)
      product = id ? Product.find_by(id: id) : Product.new
      return Failure(:not_found) unless product

      product.assign_attributes(name: name, deleted: deleted)
      product.revision += 1 if product.persisted?
      product.save ? Success(product) : Failure(product.errors.full_messages)
    end

    def enqueue(product)
      OutboxEntry.create!(payload: { 'product_id' => product.id })
      Success(product)
    end
  end
end
