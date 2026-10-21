# frozen_string_literal: true

module Answering
  class AnswersController < ApplicationController
    include Access::AuthenticatedRequest

    def create
      answers = Answers.new(catalog: Rails.configuration.x.knowledge, search: Rails.configuration.x.search)
      render json: answers.call(principal: principal, question: params.fetch(:question))
    rescue Access::Identity::Denied
      head :unauthorized
    rescue Answers::InvalidCitation
      render json: { error: 'evidence_changed' }, status: :conflict
    end
  end
end
