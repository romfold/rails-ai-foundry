# frozen_string_literal: true

module Access
  module AuthenticatedRequest
    private

    def principal
      @principal ||= Identity.authenticate(request.headers['Authorization'] || session[:demo_token])
    end
  end
end
