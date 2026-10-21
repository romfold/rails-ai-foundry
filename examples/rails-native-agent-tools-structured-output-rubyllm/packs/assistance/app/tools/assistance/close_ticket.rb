# frozen_string_literal: true

module Assistance
  class CloseTicket < RubyLLM::Tool
    description 'Close a ticket when the current user has close permission.'
    param :ticket_id, type: :integer

    def initialize(actor_id:)
      @actor_id = actor_id
      super()
    end

    def execute(ticket_id:)
      User.transaction do
        actor = User.lock.find_by(id: @actor_id, active: true, can_close: true)
        ticket = Ticket.lock.find_by(id: ticket_id, tenant: actor.tenant) if actor
        return { error: 'forbidden' } unless ticket

        ticket.update!(status: 'closed')
        { 'id' => ticket.id, 'status' => ticket.status }
      end
    end
  end
end
