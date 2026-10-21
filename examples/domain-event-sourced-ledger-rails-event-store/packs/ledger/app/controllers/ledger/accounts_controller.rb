# frozen_string_literal: true

module Ledger
  class AccountsController < ApplicationController
    skip_forgery_protection
    before_action :authorize_tenant

    def show
      account = Account.new(RailsEventStore::JSONClient.new.read.stream(stream).to_a)
      render json: { balance: account.balance, version: account.version }
    end

    def create
      result = Commands::PostMoney.new.call(tenant: @tenant, account_id: params[:id],
                                            cents: params[:cents], expected_version: params[:expected_version])
      if result.success?
        account = result.value!
        render json: { balance: account.balance, version: account.version }, status: :created
      else
        render json: { error: result.failure }, status: result.failure == :conflict ? :conflict : :unprocessable_entity
      end
    end

    private

    def stream
      "Ledger$#{@tenant}$#{params[:id]}"
    end

    def authorize_tenant
      @tenant = { 'Bearer demo-a' => 'a', 'Bearer demo-b' => 'b' }[request.authorization]
      head :unauthorized unless @tenant
    end
  end
end
