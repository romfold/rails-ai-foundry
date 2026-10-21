# frozen_string_literal: true

require_relative 'files'

module RailsAIFoundry
  module Conventions
    class Intent
      PROFILES = %w[rails_native modular domain].freeze
      PATTERNS = { 'events' => %w[none integration event_sourced], 'cqrs' => %w[none queries read_model] }.freeze
      KEYS = %w[schema kind profile namespace patterns capabilities].freeze
      NAMESPACE = /\A[A-Z][A-Za-z0-9]*(?:::[A-Z][A-Za-z0-9]*)*\z/

      attr_reader :data

      def initialize(data)
        raise ConfigurationError, 'Context intent must be a mapping.' unless data.is_a?(Hash)

        @data = { 'schema' => 1, 'kind' => 'domain', 'profile' => 'rails_native',
                  'patterns' => {}, 'capabilities' => {} }.merge(data)
        validate!
        @data['patterns'] = { 'events' => 'none', 'cqrs' => 'none' }.merge(@data['patterns'])
      end

      def self.load(root, pack_path)
        files = Files.new(root)
        new(files.yaml("#{pack_path}/foundry.yml"))
      end

      def self.validate_profile!(profile)
        return if PROFILES.include?(profile)

        raise ConfigurationError, "Unknown profile #{profile.inspect}; use #{PROFILES.join(', ')}."
      end

      def profile
        data.fetch('profile')
      end

      def namespace
        data.fetch('namespace')
      end

      private

      def validate!
        validate_shape!
        self.class.validate_profile!(data['profile'])
        unless data['namespace'].is_a?(String) && NAMESPACE.match?(data['namespace'])
          raise ConfigurationError, 'Context namespace must be a Ruby constant path, such as Billing or Platform::Search.'
        end

        validate_patterns!
        validate_capabilities!
      end

      def validate_shape!
        unknown = data.keys - KEYS
        unless unknown.empty?
          raise ConfigurationError, "Unknown context fields: #{unknown.join(', ')}; topology belongs in package.yml."
        end
        raise ConfigurationError, 'Context schema must be integer 1.' unless data['schema'].eql?(1)
        return if %w[domain platform].include?(data['kind'])

        raise ConfigurationError, 'Context kind must be domain or platform.'
      end

      def validate_patterns!
        patterns = data['patterns']
        unless patterns.is_a?(Hash) && (patterns.keys - PATTERNS.keys).empty?
          raise ConfigurationError, 'Patterns must be a mapping containing only events and cqrs.'
        end

        patterns.each do |name, value|
          next if PATTERNS.fetch(name).include?(value)

          raise ConfigurationError, "Invalid patterns.#{name}; use #{PATTERNS.fetch(name).join(', ')}."
        end
      end

      def validate_capabilities!
        capabilities = data['capabilities']
        valid = capabilities.is_a?(Hash) && capabilities.all? do |name, selection|
          name.is_a?(String) && capability_selection?(selection)
        end
        return if valid

        raise ConfigurationError, 'Capabilities must be keyed mappings with a nonempty adapter selection.'
      end

      def capability_selection?(selection)
        selection.is_a?(Hash) && selection['adapter'].is_a?(String) &&
          !selection['adapter'].empty? && selection.keys.all?(String)
      end
    end
  end
end
