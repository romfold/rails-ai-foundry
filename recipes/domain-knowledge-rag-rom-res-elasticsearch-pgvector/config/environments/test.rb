# frozen_string_literal: true

Rails.application.configure do
  config.action_controller.allow_forgery_protection = false
  config.active_job.queue_adapter = :solid_queue
end
