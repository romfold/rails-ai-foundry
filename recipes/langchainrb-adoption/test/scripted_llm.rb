# frozen_string_literal: true

require 'langchain'

# Use the upstream adapter and response types while replacing only provider I/O.
class ScriptedLLM < Langchain::LLM::OpenAI
  attr_reader :calls

  # The parent initializes a network client; this double replaces provider I/O.
  def initialize(responses) # rubocop:disable Lint/MissingSuper
    @responses = responses.dup
    @calls = []
  end

  def chat(**params)
    @calls << params
    response = @responses.shift
    raise response if response.is_a?(Exception)
    raise IOError, 'No scripted response remains' unless response

    payload = { 'choices' => [{ 'message' => response }],
                'usage' => { 'prompt_tokens' => 3, 'completion_tokens' => 2, 'total_tokens' => 5 } }
    Langchain::LLM::OpenAIResponse.new(payload)
  end
end
