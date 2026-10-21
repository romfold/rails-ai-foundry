# frozen_string_literal: true

module Assistance
  class DemoSessionsController < ApplicationController
    layout 'assistance'
    def new; end

    def create
      # Deliberately limited demo login, not production authentication.
      token = { 'reader' => 'demo-reader', 'editor' => 'demo-editor' }[params[:identity]]
      actor = User.find_by!(token: token, active: true) if token
      return head :unauthorized unless actor

      reset_session
      session[:actor_id] = actor.id
      redirect_to resolutions_path, status: :see_other
    end
  end
end
