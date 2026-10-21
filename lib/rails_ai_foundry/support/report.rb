# frozen_string_literal: true

module RailsAIFoundry
  module Support
    Diagnostic = Struct.new(:rule, :path, :message, :context, keyword_init: true) do
      def sort_key
        [path, rule, context.to_s, message]
      end

      def to_s
        subject = context ? " (#{context})" : ''
        "#{path}: [#{rule}]#{subject} #{message}"
      end
    end

    class Report
      def initialize
        @diagnostics = []
      end

      def add(rule, path, message, context: nil)
        @diagnostics << Diagnostic.new(rule: rule, path: path, message: message, context: context)
        false
      end

      def diagnostics
        @diagnostics.uniq.sort_by(&:sort_key)
      end

      def success?
        @diagnostics.empty?
      end
    end
  end
end
