# frozen_string_literal: true

class LegacyReportsController < ApplicationController
  def show
    render json: { paid_cents: LegacySalesReport.total_paid_cents }
  end
end
