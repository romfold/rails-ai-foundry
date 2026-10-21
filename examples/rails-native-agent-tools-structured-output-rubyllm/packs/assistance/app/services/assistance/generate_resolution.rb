# frozen_string_literal: true

module Assistance
  class GenerateResolution
    LEASE = 90.seconds
    MAX_ATTEMPTS = 3

    def self.call(id, provider: ResolutionAgent.new, checkpoint: ->(_point) {})
      token = claim(id, provider.provenance)
      return unless token

      request = ResolutionRequest.find(id)
      begin
        proposal = provider.call(snapshot: request.snapshot, question: request.question)
        checkpoint.call(:after_provider)
        finish(id, token, proposal: proposal)
      rescue StandardError => e
        code = e.is_a?(Timeout::Error) ? 'provider_timeout' : 'provider_or_output_failure'
        finish(id, token, failure: code)
      end
    end

    def self.claim(id, provenance)
      token = nil
      ResolutionAccess.locked(id) do |request, ticket, users|
        next unless eligible?(request)

        unless ResolutionAccess.current?(request, ticket, users)
          ResolutionAccess.stale(request, ResolutionAccess.invalid_reason(request, ticket, users))
          next
        end
        expire_attempt(request) if request.state == 'generating'
        next if exhausted?(request)

        token = begin_attempt(request, provenance)
      end
      token
    end

    def self.begin_attempt(request, provenance)
      token = SecureRandom.uuid
      request.update!(state: 'generating', lease_token: token, lease_expires_at: LEASE.from_now,
                      attempt_count: request.attempt_count + 1)
      GenerationAttempt.create!(resolution_request_id: request.id, token: token, number: request.attempt_count,
                                provider: provenance, state: 'running')
      ResolutionAccess.audit(request, 'generating', details: { attempt: request.attempt_count })
      token
    end

    def self.eligible?(request)
      (request.state == 'queued' && request.next_attempt_at <= Time.current) ||
        (request.state == 'generating' && request.lease_expires_at <= Time.current)
    end

    def self.exhausted?(request)
      return false if request.attempt_count < MAX_ATTEMPTS

      request.update!(state: 'failed', failure_code: 'attempts_exhausted', lease_token: nil, lease_expires_at: nil)
      ResolutionAccess.audit(request, 'failed')
      true
    end

    def self.owned?(request, token)
      request.state == 'generating' && request.lease_token == token && request.lease_expires_at > Time.current
    end

    def self.valid_proposal?(proposal)
      proposal.is_a?(String) && (1..2000).cover?(proposal.length)
    end

    def self.expire_attempt(request)
      GenerationAttempt.find_by!(token: request.lease_token).update!(state: 'expired', finished_at: Time.current,
                                                                     failure_code: 'lease_expired')
    end

    def self.finish(id, token, proposal: nil, failure: nil)
      ResolutionAccess.locked(id) do |request, ticket, users|
        next unless owned?(request, token)

        attempt = GenerationAttempt.find_by!(token: token)
        unless ResolutionAccess.current?(request, ticket, users)
          attempt.update!(state: 'discarded', finished_at: Time.current, failure_code: 'source_or_authority_changed')
          ResolutionAccess.stale(request, ResolutionAccess.invalid_reason(request, ticket, users))
          next
        end
        failure ||= 'invalid_output' unless valid_proposal?(proposal)
        if failure
          failed(request, attempt, failure)
        else
          succeeded(request, attempt, proposal)
        end
      end
    end

    def self.succeeded(request, attempt, proposal)
      request.update!(state: 'awaiting_review', proposal: proposal, proposal_digest: Digest::SHA256.hexdigest(proposal),
                      lease_token: nil, lease_expires_at: nil, failure_code: nil)
      attempt.update!(state: 'succeeded', finished_at: Time.current)
      ResolutionAccess.audit(request, 'awaiting_review', details: { proposal_digest: request.proposal_digest })
    end

    def self.failed(request, attempt, code)
      exhausted = request.attempt_count >= MAX_ATTEMPTS
      request.update!(state: exhausted ? 'failed' : 'queued', failure_code: code,
                      next_attempt_at: (10 * request.attempt_count).seconds.from_now,
                      lease_token: nil, lease_expires_at: nil)
      attempt.update!(state: 'failed', failure_code: code, finished_at: Time.current)
      ResolutionAccess.audit(request, request.state, details: { code: code })
    end
    private_class_method :expire_attempt, :failed
  end
end
