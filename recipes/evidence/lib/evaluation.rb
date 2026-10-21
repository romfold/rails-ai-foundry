# frozen_string_literal: true

module Evidence
  module Evaluation
    def self.score(expected:, actual:)
      validate!(actual)
      expected_ids = expected.fetch('citations').uniq
      actual_ids = actual.fetch('citations').uniq
      correct = actual['answer'] == expected.fetch('answer')
      { 'answer_correct' => correct,
        'citation_precision' => ratio(actual_ids & expected_ids, actual_ids, empty: expected_ids.empty? ? 1.0 : 0.0),
        'citation_recall' => ratio(actual_ids & expected_ids, expected_ids, empty: 1.0),
        'passed' => correct && actual_ids.sort == expected_ids.sort }
    end

    def self.validate!(actual)
      return if actual.is_a?(Hash) && actual['citations'].is_a?(Array) &&
                actual['citations'].all?(String)

      raise ArgumentError, 'Expected answer and citation string array'
    end

    def self.ratio(numerator, denominator, empty:)
      denominator.empty? ? empty : numerator.size.fdiv(denominator.size)
    end
    private_class_method :validate!, :ratio
  end
end
