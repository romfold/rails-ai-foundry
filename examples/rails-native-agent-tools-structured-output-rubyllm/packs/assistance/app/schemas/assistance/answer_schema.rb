# frozen_string_literal: true

module Assistance
  class AnswerSchema < RubyLLM::Schema
    integer :ticket_id
    string :status
    string :summary
  end
end
