# frozen_string_literal: true

module Assistance
  class ExecuteResolution
    def self.executable?(request, ticket, users)
      ResolutionAccess.current?(request, ticket, users) &&
        ResolutionAccess.authorized?(users[request.approver_id], request.tenant, editor: true) &&
        request.proposal.present? && Digest::SHA256.hexdigest(request.proposal) == request.proposal_digest
    end

    def self.invalid_code(request, ticket, users)
      return ResolutionAccess.invalid_reason(request, ticket, users) unless ResolutionAccess.current?(request, ticket,
                                                                                                      users)
      return 'approver_revoked' unless ResolutionAccess.authorized?(users[request.approver_id], request.tenant,
                                                                    editor: true)

      'proposal_changed'
    end

    def self.call(id, checkpoint: ->(_point) {})
      result = ResolutionAccess.locked(id) do |request, ticket, users|
        next unless request.state == 'approved'

        unless executable?(request, ticket, users)
          ResolutionAccess.stale(request, invalid_code(request, ticket, users))
          next
        end
        ticket.update!(status: 'closed', approved_resolution: request.proposal)
        request.update!(state: 'completed', completed_at: Time.current)
        ResolutionAccess.audit(request, 'completed', actor_id: request.approver_id,
                                                     details: { resolution: request.proposal,
                                                                proposal_digest: request.proposal_digest,
                                                                revision: request.source_revision })
        checkpoint.call(:before_commit)
      end
      checkpoint.call(:after_commit)
      result
    end
  end
end
