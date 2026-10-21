# frozen_string_literal: true

module Answering
  class RetrieveEvidence < RubyLLM::Tool
    description 'Retrieve currently published evidence authorized for this tenant.'
    param :query, type: :string

    def initialize(principal:, search:)
      @principal = principal
      @search = search
      super()
    end

    def execute(query:)
      Access::Identity.authorize!(@principal, @principal.tenant_id)
      result = @search.retrieve(principal: @principal, query: query)
      evidence = result.fetch(:documents).map do |document|
        { 'id' => document[:id], 'revision' => document[:revision], 'text' => document[:body] }
      end
      { 'documents' => evidence, 'incomplete' => result.fetch(:incomplete) }
    end
  end
end
