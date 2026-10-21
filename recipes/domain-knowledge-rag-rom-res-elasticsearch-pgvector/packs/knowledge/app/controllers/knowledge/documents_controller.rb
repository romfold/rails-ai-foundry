# frozen_string_literal: true

module Knowledge
  class DocumentsController < ApplicationController
    include Access::AuthenticatedRequest

    rescue_from Access::Identity::Denied, with: :unauthorized

    def index
      @documents = catalog.list(principal: principal, after: params[:after])
      @deliveries = catalog.delivery_status(principal: principal, ids: @documents.pluck(:id))
      respond_to do |format|
        format.html
        format.json { render json: { documents: @documents, next_cursor: @documents.last&.fetch(:id) } }
      end
    rescue ArgumentError
      render json: { error: 'invalid_cursor' }, status: :unprocessable_entity
    end

    def create
      change(action: 'create', attributes: attributes)
    end

    def update
      change(action: params.fetch(:transition, 'edit'), id: params[:id],
             expected_revision: Integer(params.fetch(:revision)), attributes: attributes)
    rescue ArgumentError, KeyError
      render json: { error: 'invalid_revision' }, status: :unprocessable_entity
    end

    private

    def catalog
      Rails.configuration.x.knowledge
    end

    def attributes
      params.permit(:title, :body).to_h.symbolize_keys
    end

    def change(**arguments)
      result = Rails.configuration.x.knowledge.change(principal: principal, **arguments)
      return render json: { error: result.failure }, status: :unprocessable_entity if result.failure?

      respond_to do |format|
        format.html { redirect_to documents_path, status: :see_other }
        format.json { render json: result.value!, status: :ok }
      end
    end

    def unauthorized
      render plain: 'Select a demo tenant from the home page, or supply an authorized bearer token.',
             status: :unauthorized
    end
  end
end
