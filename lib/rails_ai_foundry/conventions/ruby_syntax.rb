# frozen_string_literal: true

require 'ripper'

module RailsAIFoundry
  module Conventions
    module RubySyntax
      module_function

      def nodes(tree, &block)
        return unless tree.is_a?(Array)

        yield tree
        tree.each { |child| nodes(child, &block) }
      end

      def constant(node)
        return unless node.is_a?(Array)

        case node.first
        when :@const then node[1]
        when :var_ref, :const_ref, :top_const_ref then constant(node[1])
        when :const_path_ref, :const_path_field
          parent = constant(node[1])
          "#{parent}::#{node[2][1]}" if parent
        end
      end

      def call(node)
        return unless node.is_a?(Array)

        case node.first
        when :call, :command_call then [node[1], node[3][1], node[3][2].first]
        when :fcall, :vcall, :command then [nil, node[1][1], node[1][2].first]
        when :method_add_arg then call(node[1])
        end
      end

      def receiver_constant(node)
        constant(node) || (call(node) && receiver_constant(call(node).first))
      end

      def models(tree, namespace = [])
        return [] unless tree.is_a?(Array)

        return scoped_models(tree, namespace) if %i[module class].include?(tree.first)

        tree.flat_map { |child| models(child, namespace) }
      end

      def scoped_models(tree, namespace)
        name = constant(tree[1])
        return [] unless name

        name = (namespace + [name]).join('::') unless name.include?('::')
        found = tree.first == :class && %w[ApplicationRecord ActiveRecord::Base].include?(constant(tree[2]))
        (found ? [name] : []) + models(tree.last, name.split('::'))
      end
    end
  end
end
