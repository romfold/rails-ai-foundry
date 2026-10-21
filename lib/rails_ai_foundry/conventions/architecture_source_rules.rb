# frozen_string_literal: true

require_relative 'ruby_syntax'

module RailsAIFoundry
  module Conventions
    class ArchitectureSourceRules
      PROVIDERS = %w[RubyLLM OpenAI Anthropic].freeze
      DOMAIN_DEPENDENCIES = (PROVIDERS + %w[Rails ActiveRecord ApplicationRecord ROM Sequel]).freeze
      WRITES = %w[create create! update update! update_all update_columns insert insert! insert_all insert_all!
                  upsert upsert_all delete delete_all destroy destroy_all touch_all].freeze
      CALLBACK = /\A(?:before|after|around)_(?:save|create|update|destroy|commit|rollback|validation)\z/
      LIMITATIONS = 'Architecture rules cover Rails/persistence/provider constants in configured app/domain, ' \
                    'direct RubyLLM/OpenAI/Anthropic calls in delivery, and writes to source-declared Active Record ' \
                    'models in queries/projections. Transaction/callback warnings are inferred syntax. ' \
                    'Aliases, inherited model bases, dynamic dispatch and indirect provider calls require review.'

      def initialize(contexts:, models:)
        @contexts = contexts
        @models = models
      end

      def call(path, source, context: context_for(path))
        tree = Ripper.sexp(source)
        return [] unless tree

        @path = path
        @context = context
        @findings = []
        inspect_nodes(tree)
        inspect_blocks(tree)
        @findings.uniq
      end

      private

      def context_for(path)
        @contexts.select { |item| path.start_with?("#{item.fetch('path')}/") }
                 .max_by { |item| item.fetch('path').size }
      end

      def inspect_nodes(tree)
        RubySyntax.nodes(tree) do |node|
          inspect_domain(node) if pure_domain?
          call = RubySyntax.call(node)
          inspect_call(call) if call
        end
      end

      def inspect_call(call)
        receiver, method, line = call
        target = RubySyntax.receiver_constant(receiver)
        if delivery? && provider?(target)
          add(line, 'delivery_provider', 'Move provider I/O behind an application-owned service or agent boundary.')
        end
        inspect_write(line) if WRITES.include?(method) && model?(target)
      end

      def inspect_write(line)
        if query?
          add(line, 'query_write', 'Read queries must not write; move mutation to a command.')
        elsif @path.include?('/projections/')
          add(line, 'projection_write', 'Review that this write updates only rebuildable projection state.',
              severity: 'warning', certainty: 'inferred')
        end
      end

      def inspect_domain(node)
        return unless %i[var_ref const_ref top_const_ref const_path_ref].include?(node.first)

        name = RubySyntax.constant(node)
        return unless name && DOMAIN_DEPENDENCIES.include?(name.split('::').first)

        token = nil
        RubySyntax.nodes(node) { |child| token ||= child if child.first == :@const }
        add(token[2].first, 'domain_dependency',
            'Keep pure-domain rules independent of Rails, persistence and providers.')
      end

      def inspect_blocks(tree)
        callbacks = callback_methods(tree)
        RubySyntax.nodes(tree) do |node|
          block = transaction_body(node, callbacks)
          inspect_provider_block(block) if block
        end
      end

      def transaction_body(node, callbacks)
        return node.last if node.first == :def && callbacks.include?(node[1][1])
        return unless node.first == :method_add_block

        method = RubySyntax.call(node[1])&.[](1)
        node.last if transaction_method?(method)
      end

      def transaction_method?(method)
        method && (method == 'transaction' || CALLBACK.match?(method))
      end

      def inspect_provider_block(block)
        RubySyntax.nodes(block) do |child|
          call = RubySyntax.call(child)
          next unless call && provider?(RubySyntax.receiver_constant(call.first))

          add(call.last, 'provider_in_transaction',
              'Review provider I/O in this transaction/callback; move it outside with revision checks.',
              severity: 'warning', certainty: 'inferred')
        end
      end

      def callback_methods(tree)
        names = []
        RubySyntax.nodes(tree) do |node|
          call = RubySyntax.call(node)
          next unless call && CALLBACK.match?(call[1])

          RubySyntax.nodes(node) do |child|
            names << child.dig(1, 1, 1) if child.first == :symbol_literal
          end
        end
        names
      end

      def pure_domain?
        return false unless @context && @context.fetch('profile') == 'domain'

        domain = File.join(@context.fetch('path'), 'app/domain/').delete_prefix('./')
        @path.delete_prefix('./').start_with?(domain)
      end

      def delivery?
        @path.match?(%r{/app/(controllers|jobs|mailers|channels)/|\Aapp/(controllers|jobs|mailers|channels)/})
      end

      def query?
        @path.include?('/queries/')
      end

      def provider?(constant)
        constant && PROVIDERS.include?(constant.split('::').first)
      end

      def model?(constant)
        constant && (@models.include?(constant) ||
          (@context && @models.include?("#{@context.fetch('namespace')}::#{constant}")))
      end

      def add(line, rule, message, severity: 'error', certainty: 'detected')
        @findings << { 'file' => @path, 'line' => line, 'rule' => "source.#{rule}",
                       'severity' => severity, 'certainty' => certainty, 'message' => message }
      end
    end
  end
end
