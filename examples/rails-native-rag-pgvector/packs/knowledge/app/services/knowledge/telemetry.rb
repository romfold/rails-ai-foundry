# frozen_string_literal: true

module Knowledge
  module Telemetry
    def self.measure(operation)
      started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      status = 'failed'
      result = yield
      status = 'ok'
      result
    ensure
      duration = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started) * 1000
      ActiveSupport::Notifications.instrument("knowledge.#{operation}", duration_ms: duration, status: status)
    end

    def self.indexed(document)
      lag = [(Time.current - document.updated_at) * 1000, 0].max
      ActiveSupport::Notifications.instrument('knowledge.indexed', index_lag_ms: lag)
    end
  end
end
