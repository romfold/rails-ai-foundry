# frozen_string_literal: true

module Search
  class DemoEmbeddings
    TOPICS = %w[refund payment invoice shipping delivery policy return account].freeze

    def call(text)
      values = TOPICS.map { |word| text.downcase.scan(/\b#{word}\w*\b/).size.to_f }
      values << 0.01
      values + Array.new(1536 - values.size, 0.0)
    end
  end
end
