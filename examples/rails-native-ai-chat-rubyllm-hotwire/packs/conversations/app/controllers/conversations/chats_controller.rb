# frozen_string_literal: true

module Conversations
  class ChatsController < ApplicationController
    include ActionController::Live

    skip_forgery_protection
    before_action :authorize_tenant, except: :index

    def index; end

    def create
      render json: Chat.create!(tenant: @tenant), status: :created
    end

    def show
      render json: Chat.where(tenant: @tenant).find(params[:id]).messages.order(:id)
    end

    def reply
      Chat.where(tenant: @tenant).find(params[:id])
      response.headers['Content-Type'] = 'text/vnd.turbo-stream.html'
      Reply.new.call(**reply_arguments) { |text| write_chunk(text) }
    rescue IOError, ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
      write_chunk('Reply unavailable. Reload history.')
    ensure
      response.stream.close
    end

    private

    def reply_arguments
      { tenant: @tenant, chat_id: params[:id], question: params.require(:question) }
    end

    def write_chunk(text)
      response.stream.write("#{view_context.turbo_stream.update('answer', html: text)}\n")
    end

    def authorize_tenant
      @tenant = { 'Bearer demo-a' => 'a', 'Bearer demo-b' => 'b' }[request.authorization]
      head :unauthorized unless @tenant
    end
  end
end
