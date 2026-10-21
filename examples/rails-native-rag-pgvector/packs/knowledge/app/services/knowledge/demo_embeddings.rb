# frozen_string_literal: true

module Knowledge
  # Deterministic local demonstration, deliberately not a production semantic model.
  class DemoEmbeddings
    VERSION = 'demo-v1'
    TOPICS = [%w[refund return money], %w[shipping delivery parcel], %w[password login account]].freeze

    def call(text)
      words = text.downcase.scan(/[a-z]+/)
      TOPICS.map { |topic| (words & topic).length.to_f } + [1.0] + Array.new(1532, 0.0)
    end
  end
end
