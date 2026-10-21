# frozen_string_literal: true

require 'ripper'
require_relative '../errors'

module RailsAIFoundry
  module Conventions
    class FoundryReferences
      LIMITATIONS = 'Explicit RailsAIFoundry constant paths only; aliases, unqualified lexical references, ' \
                    'dynamic lookup, require calls, ERB and non-Ruby files need review. ' \
                    'Constant resolution is not proven. No dependency/privacy or behavioral verification.'

      def call(path, source)
        raise ConfigurationError, "Source disappeared during verification: #{path}" unless source

        tree = Ripper.sexp(source)
        return [diagnostic(path, 1, 'source.syntax', 'Ruby source could not be parsed.')] unless tree

        references(tree).filter_map do |name, line|
          parts = name.delete_prefix('::').split('::')
          next unless parts.first == 'RailsAIFoundry'

          diagnostic(path, line, 'source.foundry_dependency',
                     "#{name} references development-only Foundry tooling. " \
                     'Use application-owned code and upstream APIs.').merge('constant' => name)
        end.uniq
      end

      private

      def references(node)
        return [] unless node.is_a?(Array)

        if node.first == :const_path_ref && (reference = constant(node))
          return [reference]
        end

        node.flat_map { |child| references(child) }
      end

      def constant(node)
        return unless node.is_a?(Array)

        case node.first
        when :@const then [node[1], node[2].first]
        when :const_ref, :top_const_ref, :var_ref then constant(node[1])
        when :const_path_ref
          parent = constant(node[1])
          ["#{parent.first}::#{node[2][1]}", parent.last] if parent
        end
      end

      def diagnostic(path, line, rule, message)
        { 'file' => path, 'line' => line, 'rule' => rule, 'severity' => 'error',
          'certainty' => 'detected', 'message' => message }
      end
    end
  end
end
