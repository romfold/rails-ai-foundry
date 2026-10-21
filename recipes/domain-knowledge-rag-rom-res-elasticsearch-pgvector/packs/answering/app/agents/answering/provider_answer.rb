# frozen_string_literal: true

module Answering
  class ProviderAnswer
    def initialize(model: Rails.application.config_for(:ai).fetch(:models).fetch(:answering).fetch(:model), chat: nil)
      @chat = chat || RubyLLM.chat(model: model)
    end

    def call(question:, evidence:)
      prompt = File.read(File.expand_path('../../prompts/answering/provider_answer/instructions.txt', __dir__))
      @chat.with_instructions(prompt).with_schema(AnswerSchema)
           .ask(JSON.generate(question: question, evidence: evidence)).content
    end
  end
end
