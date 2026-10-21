# frozen_string_literal: true

module Search
  class Retrieval
    def initialize(catalog:, vectors:)
      @catalog = catalog
      @vectors = vectors
      @result_limit = Rails.configuration.x.knowledge_limits.fetch(:retrieval_results)
      @candidate_limit = Rails.configuration.x.knowledge_limits.fetch(:retrieval_candidates)
    end

    def call(principal:, vector:)
      documents = []
      scanned = 0
      cursor = nil
      version = @vectors.active_version
      while documents.size < @result_limit && scanned < @candidate_limit
        batch = @vectors.candidates(tenant_id: principal.tenant_id, vector: vector, version: version,
                                    limit: [20, @candidate_limit - scanned].min, after: cursor)
        break if batch.empty?

        documents.concat(current_documents(principal, batch))
        scanned += batch.size
        cursor = batch.last
      end
      result(documents, scanned)
    end

    private

    def current_documents(principal, batch)
      current = @catalog.visible(principal: principal, ids: batch.pluck(:document_id)).index_by { |row| row[:id] }
      batch.filter_map do |candidate|
        row = current[candidate[:document_id]]
        row if row && row[:revision] == candidate[:revision]
      end
    end

    def result(documents, scanned)
      incomplete = documents.size < @result_limit && scanned == @candidate_limit
      ActiveSupport::Notifications.instrument('retrieval_budget.knowledge', candidates: scanned, incomplete: incomplete)
      { documents: documents.first(@result_limit), incomplete: incomplete }
    end
  end
end
