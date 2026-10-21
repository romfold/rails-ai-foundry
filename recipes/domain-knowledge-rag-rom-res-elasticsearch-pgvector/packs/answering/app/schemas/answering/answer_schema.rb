# frozen_string_literal: true

module Answering
  class AnswerSchema < RubyLLM::Schema
    string :text
    array :citations do
      string
    end
  end
end
