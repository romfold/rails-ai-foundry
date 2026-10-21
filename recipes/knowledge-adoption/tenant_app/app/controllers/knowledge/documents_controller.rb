# frozen_string_literal: true

module Knowledge
  class DocumentsController < ApplicationController
    rescue_from ActiveRecord::RecordNotFound, with: -> { head :not_found }
    rescue_from ActiveRecord::StaleObjectError, with: -> { head :conflict }
    rescue_from ActiveRecord::RecordInvalid, with: -> { head :unprocessable_entity }

    def index
      render json: catalog.list(tenant: tenant)
    end

    def create
      render json: catalog.create(tenant: tenant, collection_id: params.require(:collection_id), **content)
    end

    def update
      render json: catalog.update(tenant: tenant, id: params[:id], revision: params.require(:revision).to_i, **content)
    end

    def destroy
      catalog.delete(tenant: tenant, id: params[:id])
      head :no_content
    end

    private

    def tenant
      Access::Identity.tenant(request.headers['Authorization'])
    end

    def catalog
      Rails.configuration.x.knowledge
    end

    def content
      params.permit(:title, :body).to_h.symbolize_keys
    end
  end
end
