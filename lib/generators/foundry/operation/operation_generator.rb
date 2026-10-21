# frozen_string_literal: true

require 'rails/generators'
require 'rails_ai_foundry/errors'

module Foundry
  class OperationGenerator < Rails::Generators::Base
    desc 'Generate a context-owned Dry::Operation scaffold'
    argument :name, type: :string
    class_option :package, type: :string
    class_option :context, type: :string
    class_option :public, type: :boolean, default: false

    def self.exit_on_failure?
      true
    end

    def create_operation
      if behavior == :revoke
        raise Rails::Generators::Error, 'Automatic removal is not supported; review the operation diff.'
      end

      installer.call(pretend: options[:pretend]).each { |action| say action }
    rescue RailsAIFoundry::InstallationError, RailsAIFoundry::ConfigurationError => e
      raise Rails::Generators::Error, e.message
    end

    private

    def installer
      unless options[:context]
        raise RailsAIFoundry::InstallationError,
              'Foundry 0.2 requires --context=NAME; create it with foundry:context NAME.'
      end

      require 'rails_ai_foundry/conventions/component_installer'
      if options[:package] || options[:public]
        raise RailsAIFoundry::InstallationError, 'Use --context alone; expose cross-pack contracts through public APIs.'
      end

      RailsAIFoundry::Conventions::ComponentInstaller.new(destination_root, name, context: options[:context],
                                                                                  kind: 'operation')
    end
  end
end
