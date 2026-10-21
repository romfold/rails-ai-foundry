# frozen_string_literal: true

require 'yaml'
require_relative '../conventions/application_config'

module RailsAIFoundry
  module Workflows
    class Selection
      CONFIG = Conventions::ApplicationConfig::PATH
      VALUES = %w[spec_kit openspec none].freeze
      ROOTS = { 'spec_kit' => '.specify', 'openspec' => 'openspec' }.freeze

      attr_reader :files, :configuration, :source

      def initialize(root)
        application = Conventions::ApplicationConfig.new(root)
        @files = application.files
        @source = application.source
        @configuration = application.data
        validate!
      end

      def resolve(explicit: nil, greenfield: false)
        return normalize(explicit) unless explicit.nil?

        configured = configuration.fetch('workflow', {})['specs']
        return normalize(configured) unless configured.nil?

        choices = detected
        if choices.size > 1
          raise ConfigurationError, 'Both Spec Kit and OpenSpec exist; select --specs=spec-kit, openspec or none.'
        end

        choices.first || (greenfield ? 'spec_kit' : 'openspec')
      end

      def detected
        ROOTS.filter_map { |name, directory| name if files.exist?(directory) }
      end

      def initialized?(name)
        return true if name == 'none'

        marker = name == 'spec_kit' ? '.specify/memory/constitution.md' : 'openspec/config.yaml'
        files.exist?(marker)
      end

      def content(name)
        updated = configuration.merge('workflow' => configuration.fetch('workflow', {}).merge('specs' => name))
        YAML.dump(updated)
      end

      private

      def normalize(value)
        normalized = value == 'spec-kit' ? 'spec_kit' : value
        return normalized if VALUES.include?(normalized)

        raise ConfigurationError, 'workflow.specs must be spec_kit, openspec or none (--specs=spec-kit is accepted).'
      end

      def validate!
        workflow = configuration.fetch('workflow', {})
        raise ConfigurationError, 'workflow must be a mapping.' unless workflow.is_a?(Hash)

        normalize(workflow['specs']) if workflow.key?('specs')
      end
    end
  end
end
