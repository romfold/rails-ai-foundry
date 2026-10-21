# frozen_string_literal: true

module Assistance
  class LookupTicket < RubyLLM::Tool
    description 'Read a ticket authorized for the current user.'
    param :ticket_id, type: :integer

    def initialize(actor_id:)
      @actor_id = actor_id
      super()
    end

    def execute(ticket_id:)
      actor = User.find_by(id: @actor_id, active: true)
      ticket = Ticket.find_by(id: ticket_id, tenant: actor.tenant) if actor
      return { error: 'not_found' } unless ticket

      ticket.attributes.slice('id', 'subject', 'status')
    end
  end
end
