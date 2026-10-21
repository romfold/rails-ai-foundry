# frozen_string_literal: true

module Assistance
  class TicketAgent
    def self.with_model(actor_id:)
      model = Rails.application.config_for(:ai).fetch(:models).fetch(:assistant)
      new(actor_id: actor_id, chat: RubyLLM.chat(model: model.fetch(:model), provider: model.fetch(:provider)))
    end

    def initialize(actor_id:, chat: nil)
      @actor_id = actor_id
      @chat = chat
    end

    def call(ticket_id:, question:)
      raise ArgumentError, 'Question must contain 1..2000 characters' unless question.is_a?(String) &&
                                                                             (1..2000).cover?(question.length)

      evidence = LookupTicket.new(actor_id: @actor_id).call(ticket_id: ticket_id)
      raise ActiveRecord::RecordNotFound if evidence.key?(:error)

      content = @chat ? ask(ticket_id, question) : demo(evidence)
      validate(content, ticket_id)
    end

    private

    def ask(ticket_id, question)
      @chat.with_instructions(File.read(File.expand_path('../../prompts/assistance/ticket/instructions.txt', __dir__)))
           .with_tools(LookupTicket.new(actor_id: @actor_id), CloseTicket.new(actor_id: @actor_id))
           .with_schema(AnswerSchema).ask(JSON.generate(ticket_id: ticket_id, question: question)).content
    end

    def demo(evidence)
      { 'ticket_id' => evidence.fetch('id'), 'status' => evidence.fetch('status'),
        'summary' => "Offline evidence: #{evidence.fetch('subject')}" }
    end

    def valid_shape?(content)
      content.is_a?(Hash) && content.keys.sort == %w[status summary ticket_id] &&
        content['summary'].is_a?(String) && (1..2000).cover?(content['summary'].length)
    end

    def validate(content, ticket_id)
      evidence = LookupTicket.new(actor_id: @actor_id).call(ticket_id: ticket_id)
      valid = valid_shape?(content) &&
              content['ticket_id'] == ticket_id && content['status'] == evidence['status'] &&
              !evidence.key?(:error)
      raise ArgumentError, 'Invalid or unauthorized structured response' unless valid

      content
    end
  end
end
