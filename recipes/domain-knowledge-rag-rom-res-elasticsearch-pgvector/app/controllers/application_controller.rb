# frozen_string_literal: true

class ApplicationController < ActionController::Base
  skip_forgery_protection if: -> { request.authorization.present? }
end
