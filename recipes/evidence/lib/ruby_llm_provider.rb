# frozen_string_literal: true

require 'ruby_llm'
require 'json'

module Evidence
  class RubyLLMProvider
    def initialize(settings)
      @settings = settings
    end

    def call(prompt, output:, timeout:)
      context = RubyLLM.context do |configuration|
        configuration.openai_api_key = @settings.key
        configuration.request_timeout = timeout
        configuration.max_retries = 0
      end
      response = context.chat(model: @settings.model, provider: :openai, assume_model_exists: true)
                        .with_params(max_completion_tokens: output).ask(prompt)
      { 'answer' => JSON.parse(response.content), 'input_tokens' => response.input_tokens,
        'output_tokens' => response.output_tokens }
    end
  end
end
