# frozen_string_literal: true

module Answering
  class Answers
    class InvalidCitation < StandardError; end

    def initialize(catalog:, search:, provider: DemoAnswer.new)
      @catalog = catalog
      @search = search
      @provider = provider
    end

    def call(principal:, question:)
      raise ArgumentError, 'Answer outside the writer transaction' if @catalog.transaction_open?

      retrieval = RetrieveEvidence.new(principal: principal, search: @search).execute(query: question)
      evidence = retrieval.fetch('documents')
      response = ApplicationTelemetry.measure('answer_provider.knowledge') do
        @provider.call(question: question, evidence: evidence)
      end
      validate!(response, evidence, principal)
      response.merge('incomplete' => retrieval.fetch('incomplete'))
    end

    private

    def validate!(response, evidence, principal)
      validate_shape!(response)
      allowed = current_evidence(evidence, principal)
      raise InvalidCitation, 'Unauthorized citation' unless (response['citations'] - allowed).empty?
    end

    def validate_shape!(response)
      valid = response.is_a?(Hash) && response['text'].is_a?(String) && response['citations'].is_a?(Array) &&
              response['citations'].all?(String)
      raise InvalidCitation, 'Invalid answer shape' unless valid
    end

    def current_evidence(evidence, principal)
      revisions = evidence.to_h { |item| [item.fetch('id'), item.fetch('revision')] }
      current = @catalog.visible(principal: principal, ids: revisions.keys)
      allowed = current.filter_map { |row| row[:id] if row[:revision] == revisions[row[:id]] }
      raise InvalidCitation, 'Evidence changed during answering' unless allowed.sort == revisions.keys.sort

      allowed
    end
  end
end
