# frozen_string_literal: true

module Assistance
  module ResolutionWakeup
    def self.call(request)
      case request.state
      when 'queued', 'generating' then GenerateResolutionJob.perform_later(request.id)
      when 'approved' then ExecuteResolutionJob.perform_later(request.id)
      end
    rescue StandardError
      # Scheduling is advisory. The recurring database sweep recovers this work.
      ActiveSupport::Notifications.instrument('assistance.scheduling_failed', request_id: request.id)
    end
  end
end
