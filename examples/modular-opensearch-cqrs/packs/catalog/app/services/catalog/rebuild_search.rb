# frozen_string_literal: true

module Catalog
  class RebuildSearch
    def initialize(search: SearchIndex.new)
      @search = search
    end

    def call(after_backfill: -> {})
      candidate = "#{@search.name}_#{SecureRandom.hex(8)}"
      @search.create(candidate)
      backfill(candidate)
      after_backfill.call
      RebuildGate.synchronize do
        # A bounded example uses a full final pass under the writers' gate. No sequence watermark race.
        backfill(candidate)
        validate!(candidate)
        @search.cutover(candidate)
      end
      candidate
    end

    def validate!(index)
      actual = @search.client.count(index: index).fetch('count')
      raise 'Projection count mismatch' unless actual == Product.count

      Product.find_each do |product|
        source = @search.client.get(index: index, id: product.id).fetch('_source')
        raise "Projection mismatch: #{product.id}" unless source == product.projection
      end
    end

    private

    def backfill(index)
      Product.find_each { |product| @search.publish({ 'product_id' => product.id }, index: index) }
    end
  end
end
