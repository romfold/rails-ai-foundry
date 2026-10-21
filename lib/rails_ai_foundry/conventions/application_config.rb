# frozen_string_literal: true

require_relative 'intent'

module RailsAIFoundry
  module Conventions
    class ApplicationConfig
      PATH = 'config/foundry.yml'
      WORKLOADS = %w[balanced read_heavy job_heavy ingestion realtime].freeze
      DEFAULT_KEYS = %w[profile patterns capabilities].freeze
      KEYS = %w[schema workload defaults workflow checks adoption].freeze
      WORKFLOWS = %w[spec_kit spec-kit openspec none].freeze
      TOPOLOGY_KEYS = %w[packages dependencies enforce_dependencies enforce_privacy public_path].freeze

      attr_reader :files, :source, :data

      def initialize(root)
        @files = Files.new(root)
        @source = files.read(PATH)
        @data = source ? files.parse_yaml(PATH, source) : {}
        validate!
      end

      def workload
        data.fetch('workload', 'balanced')
      end

      def defaults
        data.fetch('defaults', {})
      end

      private

      def validate!
        if data.keys.intersect?(TOPOLOGY_KEYS)
          raise ConfigurationError, 'Package topology belongs in package.yml, not config/foundry.yml.'
        end

        validate_contract!
        unless WORKLOADS.include?(workload)
          raise ConfigurationError, "workload must be one of: #{WORKLOADS.join(', ')}."
        end

        validate_mappings!
        validate_defaults!
        validate_workflow!
        validate_policies!
      end

      def validate_mappings!
        %w[defaults workflow checks adoption].each do |key|
          raise ConfigurationError, "#{key} must be a mapping." unless data.fetch(key, {}).is_a?(Hash)
        end
      end

      def validate_policies!
        %w[checks adoption].each do |key|
          next if data.fetch(key, {}).empty?

          raise ConfigurationError, "#{key} has no supported policy keys in schema 1; " \
                                    'use explicit check/audit CLI options and preserve Packwerk baselines.'
        end
      end

      def validate_contract!
        unless data.fetch('schema', 1).eql?(1)
          raise ConfigurationError, 'Application schema must be integer 1; review the Foundry upgrade guide.'
        end

        unknown = data.keys - KEYS
        return if unknown.empty?

        raise ConfigurationError, "Unknown application fields: #{unknown.join(', ')}; " \
                                  "supported fields: #{KEYS.join(', ')}."
      end

      def validate_workflow!
        workflow = data.fetch('workflow', {})
        unless (workflow.keys - ['specs']).empty?
          raise ConfigurationError, 'workflow may contain only specs; use spec_kit, openspec or none.'
        end
        return unless workflow.key?('specs') && !WORKFLOWS.include?(workflow['specs'])

        raise ConfigurationError, 'workflow.specs must be spec_kit, openspec or none (--specs=spec-kit is accepted).'
      end

      def validate_defaults!
        unless (defaults.keys - DEFAULT_KEYS).empty?
          raise ConfigurationError,
                'defaults may contain profile, patterns and capabilities; ownership belongs in packs.'
        end

        Intent.new(defaults.merge('namespace' => 'Default'))
      end
    end
  end
end
