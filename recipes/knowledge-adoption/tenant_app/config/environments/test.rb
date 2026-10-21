# frozen_string_literal: true

Rails.application.configure do
  # Replay migrates explicitly and verifies existing data; tests must not recreate it.
  config.active_record.maintain_test_schema = false
  config.action_controller.allow_forgery_protection = false
  config.active_job.queue_adapter = :inline
end
