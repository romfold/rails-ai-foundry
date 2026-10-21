# frozen_string_literal: true

module RailsAIFoundry
  module Support
    module CommandText
      def self.normalize(text)
        text.dup.force_encoding(Encoding::UTF_8).scrub
      end
    end
  end
end
