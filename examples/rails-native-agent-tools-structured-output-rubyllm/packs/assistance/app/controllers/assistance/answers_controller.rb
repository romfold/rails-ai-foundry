# frozen_string_literal: true

module Assistance
  class AnswersController < ApplicationController
    skip_forgery_protection
    before_action :authorize_actor

    def create
      result = TicketAgent.new(actor_id: @actor.id).call(ticket_id: Integer(params.require(:ticket_id)),
                                                         question: params.require(:question))
      render json: result
    rescue ArgumentError
      render json: { error: 'Invalid response or input' }, status: :unprocessable_entity
    end

    private

    def authorize_actor
      @actor = User.find_by(token: request.authorization.to_s.delete_prefix('Bearer '), active: true)
      head :unauthorized unless @actor
    end
  end
end
