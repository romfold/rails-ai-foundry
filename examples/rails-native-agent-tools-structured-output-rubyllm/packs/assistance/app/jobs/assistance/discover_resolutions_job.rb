# frozen_string_literal: true

module Assistance
  class DiscoverResolutionsJob < ApplicationJob
    def perform
      now = Time.current
      ResolutionRequest.where("(state = 'queued' AND next_attempt_at <= ?) OR " \
                              "(state = 'generating' AND lease_expires_at <= ?) OR state = 'approved'", now, now)
                       .order(:updated_at, :id).limit(50).each { |request| ResolutionWakeup.call(request) }
    end
  end
end
