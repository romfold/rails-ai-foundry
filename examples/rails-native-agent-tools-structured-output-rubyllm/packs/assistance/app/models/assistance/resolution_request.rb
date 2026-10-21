# frozen_string_literal: true

module Assistance
  class ResolutionRequest < ApplicationRecord
    self.table_name = 'resolution_requests'
    attr_readonly :ticket_id, :requester_id, :tenant, :snapshot, :question, :source_revision, :input_digest,
                  :idempotency_key, :previous_request_id
    validate :immutable_proposal, on: :update

    def immutable_proposal
      return unless proposal_in_database
      return unless will_save_change_to_proposal? || will_save_change_to_proposal_digest?

      errors.add(:proposal, 'cannot be edited')
    end

    ACTIVE = %w[queued generating awaiting_review approved].freeze
    def terminal?
      !ACTIVE.include?(state)
    end
  end
end
