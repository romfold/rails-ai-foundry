# frozen_string_literal: true

module Catalog
  class ProductsController < ApplicationController
    skip_forgery_protection
    before_action :authorize_editor, only: :create

    def create
      result = SaveProduct.new.call(name: params.require(:name), id: params[:id])
      if result.success?
        render json: result.value!.attributes, status: :created
      else
        render json: { error: result.failure }, status: :unprocessable_entity
      end
    end

    def index
      render json: SearchIndex.new.search(params.require(:q))
    rescue OpenSearch::Transport::Transport::Error, Faraday::Error
      render json: { error: 'Search unavailable; authoritative writes remain available' }, status: :service_unavailable
    end

    private

    def authorize_editor
      expected = "Bearer #{ENV.fetch('EDITOR_TOKEN', 'local-editor')}"
      head :unauthorized unless ActiveSupport::SecurityUtils.secure_compare(request.authorization.to_s, expected)
    end
  end
end
