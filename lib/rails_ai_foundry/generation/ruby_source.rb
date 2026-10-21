# frozen_string_literal: true

module RailsAIFoundry
  module Generation
    module RubySource
      def self.definition(constant, body, superclass: nil)
        parts = constant.split('::')
        lines = openings(parts, superclass)
        lines.concat(indent(body, parts.length))
        lines.concat(parts.length.times.to_a.reverse.map { |index| "#{'  ' * index}end" })
        lines.join("\n")
      end

      def self.indent(body, depth)
        body.lines.map { |line| line.strip.empty? ? '' : "#{'  ' * depth}#{line.chomp}" }
      end

      def self.openings(parts, superclass)
        lines = parts[0...-1].each_with_index.map { |part, index| "#{'  ' * index}module #{part}" }
        suffix = superclass ? " < #{superclass}" : ''
        lines << "#{'  ' * (parts.length - 1)}class #{parts.last}#{suffix}"
      end
    end
  end
end
