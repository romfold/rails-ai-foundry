# frozen_string_literal: true

module Knowledge
  class RebuildSearch
    def call(index:, after_backfill: -> {})
      candidate = index.create_candidate
      index.replace(candidate, documents)
      after_backfill.call
      Document.transaction do
        index.replace(candidate, documents)
        raise 'candidate validation failed' unless index.valid?(candidate, documents)

        index.activate(candidate)
      end
      candidate
    end

    private

    def documents
      Document.where(published: true).order(:id).map do |document|
        document.attributes.slice('id', 'tenant_id', 'body', 'revision')
      end
    end
  end
end
