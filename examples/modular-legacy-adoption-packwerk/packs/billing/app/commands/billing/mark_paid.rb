# frozen_string_literal: true

require 'dry/operation'

module Billing
  class MarkPaid < Dry::Operation
    skip_prepending

    def call(id)
      result = nil
      ApplicationRecord.transaction(requires_new: true) do
        result = steps { step persist(id) }
        raise ActiveRecord::Rollback if result.failure?
      end
      result
    end

    private

    def persist(id)
      invoice = Invoice.lock.find_by(id: id)
      return Failure(:not_found) unless invoice

      invoice.update!(status: 'paid') unless invoice.status == 'paid'
      Success(invoice)
    end
  end
end
