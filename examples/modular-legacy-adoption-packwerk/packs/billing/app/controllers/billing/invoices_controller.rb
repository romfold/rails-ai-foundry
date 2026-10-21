# frozen_string_literal: true

module Billing
  class InvoicesController < ApplicationController
    def index
      @invoices = Invoice.order(:reference).limit(100)
    end

    def pay
      result = MarkPaid.new.call(params[:id])
      return head :not_found if result.failure?

      redirect_to root_path, status: :see_other
    end
  end
end
