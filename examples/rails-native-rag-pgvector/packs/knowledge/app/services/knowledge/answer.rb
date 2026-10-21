# frozen_string_literal: true

module Knowledge
  class Answer
    def initialize(retriever: Retrieve.new, generator: EvidenceAnswer.new)
      @retriever = retriever
      @generator = generator
    end

    def call(tenant_id:, question:)
      passages = @retriever.call(tenant_id: tenant_id, question: question)
      return { 'text' => 'The available sources are insufficient.', 'citations' => [] } if passages.empty?

      answer = @generator.call(question: question, passages: passages)
      citations = answer.fetch('citations')
      unless answer.fetch('text').is_a?(String) && citations.is_a?(Array) && !citations.empty? &&
             (citations - passages.pluck('citation')).empty?
        raise ArgumentError, 'Answer must cite only retrieved evidence'
      end

      answer.merge('sources' => passages)
    end
  end
end
