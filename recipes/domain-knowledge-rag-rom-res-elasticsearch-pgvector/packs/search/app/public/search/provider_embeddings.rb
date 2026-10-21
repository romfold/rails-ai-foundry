# frozen_string_literal: true

module Search
  class ProviderEmbeddings
    def initialize(model: Rails.application.config_for(:ai).fetch(:models).fetch(:embedding).fetch(:model))
      @model = model
    end

    def call(text)
      RubyLLM.embed(text, model: @model, dimensions: 1536).vectors
    end
  end
end
