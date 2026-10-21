# frozen_string_literal: true

module Assistance
  class ReviewResolution
    def self.call(id:, actor_id:, decision:, digest: nil, revision: nil)
      conflict = nil
      request = ResolutionAccess.locked(id, actor_id: actor_id) do |work, ticket, users|
        actor = users[actor_id]
        raise ActiveRecord::RecordNotFound unless actor

        authorize!(work, actor, decision)

        if decision != 'cancel' && !ResolutionAccess.current?(work, ticket, users)
          ResolutionAccess.stale(work, ResolutionAccess.invalid_reason(work, ticket, users))
          conflict = 'Source or authorization changed'
        else
          apply(work, actor, decision, digest, revision)
        end
      end
      raise ResolutionAccess::Conflict, conflict if conflict

      ActiveRecord.after_all_transactions_commit { ResolutionWakeup.call(request) }
      request
    end

    def self.authorize!(work, actor, decision)
      raise ActiveRecord::RecordNotFound unless actor.tenant == work.tenant
      raise ResolutionAccess::Forbidden unless ResolutionAccess.authorized?(actor, work.tenant)

      allowed = actor.can_close || (decision == 'cancel' && actor.id == work.requester_id)
      raise ResolutionAccess::Forbidden unless allowed
      raise ResolutionAccess::Conflict, 'Request is already terminal' if work.terminal?
    end

    def self.approve(work, actor, digest, revision)
      unless digest == work.proposal_digest && revision.to_s == work.source_revision.to_s &&
             Digest::SHA256.hexdigest(work.proposal) == digest
        raise ResolutionAccess::Conflict, 'Proposal or revision mismatch'
      end

      work.update!(state: 'approved', approver_id: actor.id, approved_at: Time.current)
    end

    def self.apply(work, actor, decision, digest, revision)
      if %w[approve reject].include?(decision) && work.state != 'awaiting_review'
        raise ResolutionAccess::Conflict, 'Proposal is not awaiting review'
      end

      case decision
      when 'approve' then approve(work, actor, digest, revision)
      when 'reject' then work.update!(state: 'rejected')
      when 'cancel'
        ResolutionAccess.discard_attempt(work, 'cancelled')
        work.update!(state: 'cancelled', lease_token: nil, lease_expires_at: nil)
      else raise ArgumentError, 'Unknown decision'
      end
      ResolutionAccess.audit(work, work.state, actor_id: actor.id,
                                               details: { proposal_digest: work.proposal_digest,
                                                          revision: work.source_revision })
    end
    private_class_method :apply, :approve, :authorize!
  end
end
