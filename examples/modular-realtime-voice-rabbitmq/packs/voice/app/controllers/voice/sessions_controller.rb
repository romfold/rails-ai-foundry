# frozen_string_literal: true

module Voice
  class SessionsController < ApplicationController
    skip_forgery_protection
    before_action :authorize_tenant

    def create
      render json: Session.create!(tenant_id: @tenant).attributes, status: :created
    end

    def control
      session = ChangeTurn.new.call(tenant_id: @tenant, session_id: params[:id], action: params.require(:action_name))
      render json: session.attributes
    end

    def push
      encoded = params.require(:data)
      return head :payload_too_large if encoded.bytesize > 5464

      result = MediaBuffer.new.push(tenant_id: @tenant, session_id: params[:id], epoch: Integer(params.require(:epoch)),
                                    sequence: Integer(params.require(:sequence)), data: Base64.strict_decode64(encoded))
      render json: { status: result }, status: result == :accepted ? :created : :conflict
    end

    def shift
      data = MediaBuffer.new.shift(tenant_id: @tenant, session_id: params[:id], epoch: Integer(params.require(:epoch)))
      render json: { data: data && Base64.strict_encode64(data) }
    end

    private

    def authorize_tenant
      tokens = JSON.parse(ENV.fetch('TENANT_TOKENS', '{"demo-a":"tenant-a","demo-b":"tenant-b"}'))
      @tenant = tokens[request.authorization.to_s.delete_prefix('Bearer ')]
      head :unauthorized unless @tenant
    end
  end
end
