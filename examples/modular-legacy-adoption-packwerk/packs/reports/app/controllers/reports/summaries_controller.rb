# frozen_string_literal: true

module Reports
  class SummariesController < ApplicationController
    def show
      render json: { paid_cents: Billing::Invoices.total_paid_cents }
    end
  end
end
