# frozen_string_literal: true

module Access
  class SessionsController < ApplicationController
    def new; end

    def create
      Identity.authenticate(params[:token])
      reset_session
      session[:demo_token] = params[:token]
      redirect_to documents_path, status: :see_other
    rescue Identity::Denied
      render plain: 'Invalid demo token', status: :unauthorized
    end

    def destroy
      reset_session
      redirect_to root_path, status: :see_other
    end
  end
end
