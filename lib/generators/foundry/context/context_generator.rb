# frozen_string_literal: true

require 'rails/generators'
require 'rails_ai_foundry/conventions/context_installer'

module Foundry
  class ContextGenerator < Rails::Generators::Base
    desc 'Create a pack with independent Foundry intent using upstream packs'
    argument :name, type: :string
    class_option :profile, type: :string
    class_option :kind, type: :string, default: 'domain'
    class_option :namespace, type: :string
    class_option :path, type: :string
    class_option :events, type: :string
    class_option :cqrs, type: :string

    def self.exit_on_failure?
      true
    end

    def create_context
      if behavior == :revoke
        raise Rails::Generators::Error, 'Automatic removal is not supported; review the context diff.'
      end

      installer.call(pretend: options[:pretend]).each { |action| say action }
    rescue RailsAIFoundry::ConfigurationError, RailsAIFoundry::InstallationError => e
      raise Rails::Generators::Error, e.message
    end

    private

    def installer
      RailsAIFoundry::Conventions::ContextInstaller.new(
        destination_root, name, profile: options[:profile], kind: options[:kind],
                                namespace: options[:namespace], path: options[:path], patterns: patterns
      )
    end

    def patterns
      { 'events' => options[:events], 'cqrs' => options[:cqrs] }.compact
    end
  end
end
