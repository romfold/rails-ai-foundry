# frozen_string_literal: true

module Conversations
  class Provider
    def initialize(chat: nil)
      model = Rails.application.config_for(:ai).fetch(:models).fetch(:chat)
      @chat = chat || RubyLLM.chat(model: model.fetch(:model), provider: model.fetch(:provider))
    end

    def call(question:, history:)
      prompt = File.expand_path('../../prompts/conversations/reply/instructions.txt', __dir__)
      @chat.with_instructions(File.read(prompt))
      history.each do |message|
        @chat.add_message(role: :user, content: message.question)
        @chat.add_message(role: :assistant, content: message.answer)
      end
      @chat.ask(question) { |chunk| yield chunk.content.to_s }
    end
  end
end
