# frozen_string_literal: true

module Knowledge
  class ProviderEmbeddings
    def initialize(model:, provider:)
      @model = model
      @provider = provider
    end

    def call(text)
      RubyLLM.embed(text, model: @model, provider: @provider, dimensions: 1536).vectors
    end
  end
end
