# frozen_string_literal: true

module Assistance
  class ResolutionsController < ApplicationController
    layout 'assistance'
    before_action :authenticate
    before_action :load_request, only: %i[show approve reject cancel retry]
    skip_forgery_protection if: :bearer_api?
    rescue_from ActiveRecord::RecordNotFound, with: -> { head :not_found }
    rescue_from ResolutionAccess::Forbidden, with: -> { head :forbidden }
    rescue_from ResolutionAccess::Conflict, with: -> { render plain: 'Request conflict; reload current status', status: :conflict }
    rescue_from ArgumentError, ActionController::ParameterMissing, with: -> { render plain: 'Invalid request', status: :unprocessable_entity }

    def index
      @tickets = Ticket.where(tenant: @actor.tenant).order(:id).limit(50)
      @requests = ResolutionRequest.where(tenant: @actor.tenant).order(id: :desc).limit(50)
    end

    def show
      if request.format.json?
        render json: representation(@work)
      elsif request.headers['Turbo-Frame'] == 'resolution-status'
        render :status, layout: false
      end
    end

    def create
      @work = RequestResolution.call(actor_id: @actor.id, ticket_id: Integer(params.require(:ticket_id).to_s, 10),
                                     question: params.require(:question), key: params.require(:idempotency_key))
      accepted
    end

    def approve
      decide('approve')
    end

    def reject
      decide('reject')
    end

    def cancel
      decide('cancel')
    end

    def retry
      @work = RequestResolution.call(actor_id: @actor.id, ticket_id: @work.ticket_id, question: @work.question,
                                     key: params.require(:idempotency_key), previous_id: @work.id)
      accepted
    end

    private

    def bearer_api?
      request.format.json? && request.authorization.to_s.start_with?('Bearer ')
    end

    def authenticate
      @actor = if bearer_api?
                 User.find_by(token: request.authorization.delete_prefix('Bearer '), active: true)
               else
                 User.find_by(id: session[:actor_id], active: true)
               end
      return if @actor

      if request.format.json?
        render json: { error: 'identity_unavailable_or_revoked' }, status: :unauthorized
      else
        render partial: 'revoked', status: :unauthorized
      end
    end

    def load_request
      @work = ResolutionRequest.where(tenant: @actor.tenant).find(params[:id])
    end

    def decide(decision)
      @work = ReviewResolution.call(id: @work.id, actor_id: @actor.id, decision: decision,
                                    digest: params[:proposal_digest], revision: params[:ticket_revision])
      accepted
    end

    def accepted
      response.set_header('Location', resolution_path(@work))
      if request.format.json?
        render json: representation(@work), status: :accepted
      else
        redirect_to resolution_path(@work), status: :see_other
      end
    end

    def representation(work)
      work.attributes.slice('id', 'state', 'snapshot', 'source_revision', 'proposal', 'proposal_digest',
                            'requester_id', 'approver_id', 'failure_code', 'attempt_count', 'completed_at')
          .merge('status_url' => resolution_path(work))
    end
  end
end
