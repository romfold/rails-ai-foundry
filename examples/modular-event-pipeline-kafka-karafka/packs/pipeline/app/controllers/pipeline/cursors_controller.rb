# frozen_string_literal: true

module Pipeline
  class CursorsController < ApplicationController
    before_action :authorize_tenant

    def show
      render json: Cursor.find_by!(tenant: @tenant, stream_key: params[:id]).attributes.slice('position', 'total')
    end

    private

    def authorize_tenant
      @tenant = { 'Bearer demo-a' => 'a', 'Bearer demo-b' => 'b' }[request.authorization]
      head :unauthorized unless @tenant
    end
  end
end
