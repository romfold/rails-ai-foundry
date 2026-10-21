# frozen_string_literal: true

# Application-owned measurements never include prompts, document bodies or credentials.
class ApplicationTelemetry
  def self.measure(name)
    started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    payload = { outcome: 'success' }
    yield
  rescue StandardError => e
    payload = { outcome: 'failure', error: e.class.name }
    raise
  ensure
    duration = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started
    ActiveSupport::Notifications.instrument(name, payload.merge(duration_ms: duration * 1000))
  end
end
