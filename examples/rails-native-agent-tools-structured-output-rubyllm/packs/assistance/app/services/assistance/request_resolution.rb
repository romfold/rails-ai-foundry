# frozen_string_literal: true

module Assistance
  class RequestResolution
    def self.call(actor_id:, ticket_id:, question:, key:, previous_id: nil)
      validate_input!(question, key)
      digest = Digest::SHA256.hexdigest(JSON.generate([ticket_id, question, previous_id]))
      request = ApplicationRecord.transaction do
        actor = User.lock.find(actor_id)
        raise ResolutionAccess::Forbidden unless actor.active

        ticket = Ticket.where(tenant: actor.tenant).lock.find(ticket_id)
        find_or_create(actor, ticket, question: question, key: key, digest: digest, previous_id: previous_id)
      end
      ActiveRecord.after_all_transactions_commit { ResolutionWakeup.call(request) }
      request
    end

    def self.validate_input!(question, key)
      raise ArgumentError, 'Question must contain 1..2000 characters' unless question.is_a?(String) &&
                                                                             (1..2000).cover?(question.length)
      raise ArgumentError, 'Idempotency key must contain 1..128 characters' unless key.is_a?(String) &&
                                                                                   (1..128).cover?(key.length)
    end

    def self.find_or_create(actor, ticket, **input)
      key, digest, previous_id = input.values_at(:key, :digest, :previous_id)
      existing = ResolutionRequest.find_by(requester_id: actor.id, idempotency_key: key)
      if existing
        raise ResolutionAccess::Conflict, 'Idempotency content changed' unless existing.input_digest == digest

        return existing
      end
      validate_previous!(previous_id, ticket, actor)
      raise ResolutionAccess::Conflict, 'Ticket is closed' unless ticket.status == 'open'
      raise ResolutionAccess::Conflict, 'Ticket already has active work' if
        ResolutionRequest.where(ticket_id: ticket.id, state: ResolutionRequest::ACTIVE).exists?

      create_request(actor, ticket, input)
    end

    def self.validate_previous!(id, ticket, actor)
      return unless id

      previous = ResolutionRequest.lock.find(id)
      raise ActiveRecord::RecordNotFound unless previous.ticket_id == ticket.id && previous.requester_id == actor.id
      raise ResolutionAccess::Conflict, 'Only failed generation can be retried' unless previous.state == 'failed'
    end

    def self.create_request(actor, ticket, input)
      question, key, digest, previous_id = input.values_at(:question, :key, :digest, :previous_id)
      request = ResolutionRequest.create!(ticket_id: ticket.id, requester_id: actor.id, tenant: actor.tenant,
                                          question: question, idempotency_key: key, input_digest: digest,
                                          previous_request_id: previous_id, source_revision: ticket.lock_version,
                                          snapshot: ticket.attributes.slice('id', 'subject', 'status', 'lock_version'),
                                          next_attempt_at: Time.current)
      ResolutionAccess.audit(request, 'requested', actor_id: actor.id)
      request
    end
    private_class_method :validate_previous!, :create_request
  end
end
