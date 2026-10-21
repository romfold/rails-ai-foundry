# frozen_string_literal: true

module Conversations
  class Reply
    def initialize(provider: DemoProvider.new)
      @provider = provider
    end

    def call(tenant:, chat_id:, question:, &block)
      chat = Chat.where(tenant: tenant).find(chat_id)
      message = chat.messages.create!(question: question)
      begin
        stream(message, &block)
        message.update!(state: 'complete')
      ensure
        message.update!(state: 'failed') if message.state == 'pending'
      end
      message
    end

    private

    def stream(message)
      history = message.chat.messages.where(state: 'complete').order(:id).last(20)
      @provider.call(question: message.question, history: history) do |chunk|
        message.answer += chunk
        raise IOError, 'Response exceeds 32000 characters' if message.answer.length > 32_000

        message.save!
        yield message.answer
      end
    end
  end
end
