# frozen_string_literal: true

module Knowledge
  class EvidenceAnswer
    def call(passages:, **)
      { 'text' => passages.map { |row| row.fetch('body') }.join("\n\n"),
        'citations' => passages.pluck('citation') }
    end
  end
end
