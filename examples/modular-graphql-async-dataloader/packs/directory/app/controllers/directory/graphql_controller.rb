# frozen_string_literal: true

module Directory
  class GraphqlController < ApplicationController
    skip_forgery_protection
    before_action :authorize_tenant

    def create
      result = Schema.execute(params.require(:query), variables: params[:variables]&.to_unsafe_h || {},
                                                      context: { tenant: @tenant, role: :reading })
      render json: result
    end

    private

    def authorize_tenant
      @tenant = { 'Bearer demo-a' => 'a', 'Bearer demo-b' => 'b' }[request.authorization]
      head :unauthorized unless @tenant
    end
  end
end
