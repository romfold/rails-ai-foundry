# frozen_string_literal: true

module Assistance
  module ResolutionAccess
    class Conflict < StandardError; end
    class Forbidden < StandardError; end

    def self.authorized?(actor, tenant, editor: false)
      actor&.active && actor.tenant == tenant && (!editor || actor.can_close)
    end

    # Identity IDs are immutable once assigned. Approval only adds an identity while
    # holding the ticket lock; retry if its ID changed before acquiring that lock.
    def self.locked(id, actor_id: nil)
      loop do
        hint = ResolutionRequest.find(id)
        outcome = ApplicationRecord.transaction do
          users = locked_users(hint, actor_id)
          ticket = Ticket.lock.find(hint.ticket_id)
          request = ResolutionRequest.lock.find(id)
          next :retry if request.approver_id && !users.key?(request.approver_id)

          yield request, ticket, users
          :done
        end
        break if outcome == :done
      end
      ResolutionRequest.find(id)
    end

    def self.locked_users(hint, actor_id)
      ids = [hint.requester_id, hint.approver_id, actor_id].compact.uniq.sort
      User.where(id: ids).order(:id).lock.index_by(&:id)
    end

    def self.discard_attempt(request, code)
      return unless request.lease_token

      GenerationAttempt.where(token: request.lease_token, state: 'running')
                       .update_all(state: 'discarded', failure_code: code, finished_at: Time.current)
    end

    def self.current?(request, ticket, users)
      invalid_reason(request, ticket, users).nil?
    end

    def self.invalid_reason(request, ticket, users)
      return 'requester_revoked' unless authorized?(users[request.requester_id], request.tenant)
      return 'ticket_changed' unless ticket.tenant == request.tenant && ticket.status == 'open' &&
                                     ticket.lock_version == request.source_revision

      nil
    end

    def self.audit(request, event, actor_id: nil, details: {})
      ActiveSupport::Notifications.instrument('assistance.resolution', request_id: request.id, event: event)
      ResolutionAudit.create!(resolution_request_id: request.id, event: event, actor_id: actor_id, details: details)
    end

    def self.stale(request, code = 'source_or_authority_changed')
      discard_attempt(request, code)
      request.update!(state: 'stale', failure_code: code, lease_token: nil, lease_expires_at: nil)
      audit(request, 'stale', details: { code: code })
    end
  end
end
