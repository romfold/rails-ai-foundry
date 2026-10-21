# frozen_string_literal: true

module Knowledge
  class Answer
    def initialize(retrieve: Retrieve.new)
      @retrieve = retrieve
    end

    def call(tenant:, question:)
      evidence = @retrieve.call(tenant: tenant, question: question)
      { answer: evidence.map { |item| "#{item.fetch(:text)} [#{item.fetch(:citation)}]" }.join("\n"),
        citations: evidence.pluck(:citation) }
    end
  end
end
