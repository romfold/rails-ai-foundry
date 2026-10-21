# frozen_string_literal: true

module Knowledge
  class AnswerSchema < RubyLLM::Schema
    string :text
    array :citations do
      string
    end
  end
end
