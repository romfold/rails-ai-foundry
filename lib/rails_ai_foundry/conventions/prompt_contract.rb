# frozen_string_literal: true

require_relative 'files'

module RailsAIFoundry
  module Conventions
    class PromptContract
      CONSTANT = /\A[A-Z][A-Za-z0-9_]*(?:::[A-Z][A-Za-z0-9_]*)*\z/
      REQUIRED = %w[schema owner agent templates inputs output_schema tools evaluations].freeze
      OPTIONAL = %w[model_alias authorization acceptance].freeze

      def initialize(files, contexts, packages:)
        @files = files
        @contexts = contexts
        @packages = packages
      end

      def call(path)
        data = @files.yaml(path)
        validate_shape!(data)
        validate_owner!(path, data)
        (data.fetch('templates') + data.fetch('evaluations')).each { |reference| validate_file!(path, reference) }
      end

      private

      def validate_shape!(data)
        validate_keys!(data)
        valid = declarations?(data) && references?(data) && inputs?(data['inputs']) && optional_fields?(data)
        raise ConfigurationError, 'Invalid prompt contract declarations; see docs/prompt-contracts.md.' unless valid
      end

      def validate_keys!(data)
        return if (REQUIRED - data.keys).empty? && (data.keys - REQUIRED - OPTIONAL).empty? && data['schema'].eql?(1)

        raise ConfigurationError, "Use prompt schema 1 with required fields: #{REQUIRED.join(', ')}."
      end

      def declarations?(data)
        constant?(data['agent']) && (data['output_schema'].nil? || constant?(data['output_schema'])) &&
          strings?(data['tools']) && data['tools'].all? { |name| constant?(name) }
      end

      def references?(data)
        %w[templates evaluations].all? { |key| strings?(data[key], nonempty: true) }
      end

      def constant?(value)
        value.is_a?(String) && CONSTANT.match?(value)
      end

      def strings?(value, nonempty: false)
        value.is_a?(Array) && (!nonempty || !value.empty?) && value.all? { |item| text?(item) }
      end

      def text?(value)
        value.is_a?(String) && !value.strip.empty?
      end

      def inputs?(value)
        value.is_a?(Hash) && value.all? { |name, trust| text?(name) && %w[trusted untrusted].include?(trust) }
      end

      def optional_fields?(data)
        %w[model_alias authorization].all? { |key| !data.key?(key) || text?(data[key]) } &&
          (!data.key?('acceptance') || strings?(data['acceptance']))
      end

      def validate_owner!(path, data)
        owner = @packages.owner(path) || '.'
        context = @contexts.find { |item| item.fetch('path') == owner }
        prefix = owner == '.' ? 'app/prompts/' : "#{owner}/app/prompts/"
        unless data['owner'] == owner && path.start_with?(prefix)
          raise ConfigurationError, 'Prompt owner must match its actual application or upstream package prompt root.'
        end

        validate_namespace!(context, data.fetch('agent')) if context
      end

      def validate_namespace!(context, agent)
        return if agent.start_with?("#{context.fetch('namespace')}::")

        raise ConfigurationError, 'Prompt agent must use its owning context namespace.'
      end

      def validate_file!(path, reference)
        if reference.start_with?('/') || reference.include?("\0") || reference.split('/').intersect?(%w[. ..])
          raise ConfigurationError, 'Prompt references must be safe paths inside the contract directory.'
        end

        target = File.join(File.dirname(path), reference)
        unless (@packages.owner(target) || '.') == (@packages.owner(path) || '.')
          raise ConfigurationError, "Prompt artifact crosses a package ownership boundary: #{target}."
        end

        inspect_artifact!(target)
      end

      def inspect_artifact!(target)
        raise ConfigurationError, "Missing prompt artifact: #{target}." unless File.file?(@files.path(target))

        File.open(@files.path(target), File::RDONLY | File::NOFOLLOW, &:stat)
      rescue SystemCallError
        raise ConfigurationError, "Cannot inspect prompt artifact: #{target}."
      end
    end
  end
end
