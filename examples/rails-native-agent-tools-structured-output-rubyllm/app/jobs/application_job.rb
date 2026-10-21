# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  self.enqueue_after_transaction_commit = true
  # Arguments contain only work IDs; business content never enters queue logs.
end
