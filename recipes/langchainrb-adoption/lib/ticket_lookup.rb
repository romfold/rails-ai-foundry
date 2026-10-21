# frozen_string_literal: true

require 'langchain'

module SupportDesk
  class TicketLookup
    extend Langchain::ToolDefinition

    class NotAuthorized < StandardError; end

    define_function :lookup, description: 'Read an authorized support ticket.' do
      property :ticket_id, type: 'integer', required: true
    end

    def initialize(tenant:, tickets:, authorize:)
      @tenant = tenant
      @tickets = tickets
      @authorize = authorize
    end

    def lookup(ticket_id:)
      raise NotAuthorized, 'Ticket access denied' unless @authorize.call(ticket_id: ticket_id).equal?(true)

      ticket = @tickets.fetch(ticket_id)
      raise NotAuthorized, 'Ticket access denied' unless ticket.fetch(:tenant) == @tenant

      JSON.generate(id: ticket_id, status: ticket.fetch(:status))
    end
  end
end
