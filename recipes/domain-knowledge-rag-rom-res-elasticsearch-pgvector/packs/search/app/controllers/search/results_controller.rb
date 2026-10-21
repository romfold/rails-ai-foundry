# frozen_string_literal: true

module Search
  class ResultsController < ApplicationController
    include Access::AuthenticatedRequest

    def index
      render json: Rails.configuration.x.search.keyword(principal: principal, query: params.fetch(:q, ''))
    rescue Access::Identity::Denied
      head :unauthorized
    rescue Elastic::Transport::Transport::Error
      render json: { error: 'search_unavailable' }, status: :service_unavailable
    end
  end
end
