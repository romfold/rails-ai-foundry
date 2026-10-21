# frozen_string_literal: true

module Knowledge
  class DocumentsController < ApplicationController
    skip_forgery_protection
    before_action :authorize_tenant

    def create
      document = Ingest.new.call(tenant_id: @tenant, title: params.require(:title), body: params.require(:body))
      render json: { id: document.id }, status: :created
    end

    def search
      render json: { passages: Retrieve.new.call(tenant_id: @tenant, question: params.require(:question)) }
    end

    def answer
      render json: Answer.new.call(tenant_id: @tenant, question: params.require(:question))
    end

    def destroy
      Document.find_by!(id: params[:id], tenant_id: @tenant).destroy!
      head :no_content
    end

    private

    def authorize_tenant
      tokens = JSON.parse(ENV.fetch('TENANT_TOKENS', '{"demo-a":"tenant-a","demo-b":"tenant-b"}'))
      @tenant = tokens[request.authorization.to_s.delete_prefix('Bearer ')]
      head :unauthorized unless @tenant
    end
  end
end
