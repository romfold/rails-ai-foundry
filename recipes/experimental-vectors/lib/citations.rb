# frozen_string_literal: true

module Knowledge
  class Citations
    def initialize(scope:, index:, documents:)
      @scope = scope
      @index = index
      @documents = documents
    end

    def current?(record, match)
      record && !record.fetch(:deleted) && record.fetch(:tenant) == @scope.tenant &&
        record.fetch(:version) == @scope.version && record.fetch(:revision) == match.fetch('revision')
    end
    private :current?

    def call(vector:)
      @index.search(vector: vector).filter_map do |match|
        record = @documents.call(tenant: @scope.tenant, id: match.fetch('id'))
        next unless current?(record, match)

        { id: record.fetch(:id), revision: record.fetch(:revision), text: record.fetch(:text) }
      end
    end
  end
end
