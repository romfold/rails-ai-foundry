# frozen_string_literal: true

require 'rails/generators'
require 'rails_ai_foundry/generation/skill_upgrade'

module Foundry
  class SkillsGenerator < Rails::Generators::Base
    desc 'Install versioned Foundry skills into the application'
    class_option :target, type: :string, default: 'agents'
    class_option :upgrade, type: :boolean, default: false
    class_option :apply, type: :string
    class_option :resolve, type: :string
    class_option :rollback, type: :string

    def self.exit_on_failure?
      true
    end

    def install_skills
      if behavior == :revoke
        raise Rails::Generators::Error, 'Automatic removal is not supported; review the installed skills.'
      end

      actions.each { |action| say action }
    rescue RailsAIFoundry::InstallationError => e
      raise Rails::Generators::Error, e.message
    end

    private

    def upgrade_command
      RailsAIFoundry::Generation::SkillUpgrade::Command.new(destination_root, target: options[:target])
    end

    def skill_installer
      RailsAIFoundry::Generation::SkillInstaller.new(destination_root, target: options[:target])
    end

    def actions
      arguments = options.slice('apply', 'resolve', 'rollback').transform_keys(&:to_sym)
      if options[:upgrade]
        upgrade_command.call(**arguments, pretend: options[:pretend])
      else
        raise Rails::Generators::Error, 'Upgrade actions require --upgrade.' if arguments.values.any?

        skill_installer.call(pretend: options[:pretend])
      end
    end
  end
end
