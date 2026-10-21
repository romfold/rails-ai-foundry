# frozen_string_literal: true

module Knowledge
  class ProviderAnswer
    def initialize(chat: nil)
      models = Rails.application.config_for(:ai).fetch(:models).fetch(:answer)
      @chat = chat || RubyLLM.chat(model: models.fetch(:model), provider: models.fetch(:provider))
    end

    def call(question:, passages:)
      prompt = File.read(File.expand_path('../../prompts/knowledge/answer/instructions.txt', __dir__))
      @chat.with_instructions(prompt).with_schema(AnswerSchema)
           .ask(JSON.generate(question: question, passages: passages)).content
    end
  end
end
