# frozen_string_literal: true

require 'rails/generators'
require 'rails_ai_foundry/errors'

module Foundry
  class AgentGenerator < Rails::Generators::Base
    desc 'Create a package-owned RubyLLM agent, tool, schema, prompt, and tests'
    argument :name, type: :string
    class_option :package, type: :string
    class_option :context, type: :string

    def self.exit_on_failure?
      true
    end

    def create_agent
      if behavior == :revoke
        raise Rails::Generators::Error, 'Automatic removal is not supported; review the agent diff.'
      end

      installer.call(pretend: options[:pretend]).each { |action| say action }
    rescue RailsAIFoundry::InstallationError, RailsAIFoundry::ConfigurationError => e
      raise Rails::Generators::Error, e.message
    end

    private

    def installer
      unless options[:context] && !options[:package]
        raise RailsAIFoundry::InstallationError,
              'Foundry 0.2 requires --context=NAME; create it with foundry:context NAME.'
      end

      require 'rails_ai_foundry/conventions/agent_installer'
      RailsAIFoundry::Conventions::AgentInstaller.new(destination_root, name, context: options[:context])
    end
  end
end
