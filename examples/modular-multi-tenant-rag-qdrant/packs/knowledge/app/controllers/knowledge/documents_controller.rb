# frozen_string_literal: true

module Knowledge
  class DocumentsController < ApplicationController
    skip_forgery_protection
    before_action :authorize_tenant

    def create
      document = SaveDocument.new.call(tenant: @tenant, title: params.require(:title), body: params.require(:body))
      render json: { id: document.id, projection: 'pending rebuild' }, status: :created
    end

    def search
      render json: Answer.new.call(tenant: @tenant, question: params.require(:q))
    rescue IOError, SystemCallError, Timeout::Error
      render json: { error: 'Retrieval unavailable' }, status: :service_unavailable
    end

    def destroy
      Gate.synchronize { Document.where(tenant: @tenant).find(params[:id]).increment(:revision).update!(deleted: true) }
      head :no_content
    end

    private

    def authorize_tenant
      @tenant = { 'Bearer demo-a' => 'a', 'Bearer demo-b' => 'b' }[request.authorization]
      head :unauthorized unless @tenant
    end
  end
end
