# frozen_string_literal: true

module Answering
  class DemoAnswer
    def call(evidence:, **)
      return { 'text' => 'No published evidence found.', 'citations' => [] } if evidence.empty?

      { 'text' => evidence.first.fetch('text'), 'citations' => [evidence.first.fetch('id')] }
    end
  end
end
