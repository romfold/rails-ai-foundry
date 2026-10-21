# frozen_string_literal: true

module Orders
  class OrdersController < ApplicationController
    skip_forgery_protection
    before_action :authorize_tenant

    def create
      result = Place.new.call(tenant: @tenant, cents: params.require(:cents))
      if result.success?
        render json: result.value!, status: :created
      else
        render json: { error: result.failure }, status: :unprocessable_entity
      end
    end

    def show
      render json: Order.where(tenant: @tenant).find(params[:id])
    end

    private

    def authorize_tenant
      @tenant = { 'Bearer demo-a' => 'a', 'Bearer demo-b' => 'b' }[request.authorization]
      head :unauthorized unless @tenant
    end
  end
end
