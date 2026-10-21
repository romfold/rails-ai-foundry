# frozen_string_literal: true

require_relative '../errors'
require 'rails/generators'

module RailsAIFoundry
  module Generation
    class ComponentGenerator < Rails::Generators::Base
      argument :name, type: :string
      argument :fields, type: :array, default: []
      class_option :package, type: :string
      class_option :context, type: :string

      def self.exit_on_failure?
        true
      end

      def create_component
        if behavior == :revoke
          raise Rails::Generators::Error, 'Automatic removal is not supported; review the component diff.'
        end

        installer.call(pretend: options[:pretend]).each { |action| say action }
      rescue InstallationError, ConfigurationError => e
        raise Rails::Generators::Error, e.message
      end

      private

      def installer
        unless options[:context]
          raise InstallationError, 'Foundry 0.2 requires --context=NAME; create it with foundry:context NAME.'
        end

        require_relative '../conventions/component_installer'
        if options[:package] || fields.any?
          raise InstallationError, 'Use --context alone; generate migrations with Rails in the application root.'
        end

        Conventions::ComponentInstaller.new(destination_root, name, context: options[:context], kind: component_kind)
      end
    end
  end
end
