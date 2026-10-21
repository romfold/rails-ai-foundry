# frozen_string_literal: true

module Knowledge
  class Rebuild
    def initialize(index: VectorIndex.new)
      @index = index
    end

    def call(after_backfill: -> {})
      candidate = "knowledge_#{SecureRandom.hex(8)}"
      @index.create(candidate)
      copy(candidate)
      after_backfill.call
      Gate.synchronize do
        copy(candidate)
        validate(candidate)
        @index.cutover(candidate)
      end
      candidate
    end

    private

    def copy(candidate)
      Document.find_each { |document| @index.upsert(document, collection: candidate) }
    end

    def matches?(point, document)
      point.fetch('payload') == document.payload &&
        point.fetch('vector').zip(document.embedding).all? { |actual, expected| (actual - expected).abs < 0.0001 }
    end

    def validate(candidate)
      points = @index.snapshot(candidate).index_by { |point| point.fetch('id') }
      raise IOError, 'Projection count mismatch' unless points.size == Document.count

      Document.find_each do |document|
        raise IOError, 'Projection content mismatch' unless matches?(points.fetch(document.id), document)
      end
    end
  end
end
