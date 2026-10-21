# frozen_string_literal: true

module Knowledge
  class DemoEmbeddings
    def call(text)
      words = text.downcase.scan(/[a-z]+/)
      vector = [%w[refund return money], %w[shipping delivery parcel], %w[account login password]].map do |topic|
        words.count { |word| topic.include?(word) }.to_f
      end
      vector[0] = 0.01 if vector.all?(&:zero?)
      norm = Math.sqrt(vector.sum { |value| value * value })
      vector.map { |value| value / norm }
    end
  end
end
