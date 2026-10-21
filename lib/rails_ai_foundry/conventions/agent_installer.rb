# frozen_string_literal: true

require_relative 'contexts'
require_relative 'agent_templates'
require_relative 'agent_receipt'
require_relative 'constant_ownership'
require_relative 'namespace_inflections'
require_relative '../generation/scaffold_installer'

module RailsAIFoundry
  module Conventions
    class AgentInstaller
      CONFIG = 'config/ai.yml'

      def initialize(root, name, context:)
        @files = Files.new(root)
        @pack, @intent = Contexts.new(root).find(context)
        raise ConfigurationError, 'Use a snake_case agent name.' unless /\A[a-z][a-z0-9_]*\z/.match?(name)

        @name = name
      end

      def call(pretend: false)
        check_capability!
        @files.yaml(CONFIG) if @files.exist?(CONFIG)
        receipt = "#{@pack}/.foundry/agents/#{@name}.yml"
        check_ownership!(receipt)
        files = owned_files(receipt)
        installer = Generation::ScaffoldInstaller.new(@files.root)
        preview = installer.install_files(files, receipt: receipt, pretend: true)
        files = with_configuration(files, preview)
        NamespaceInflections.new(@files.root, @pack, @intent).install(files, receipt: receipt, pretend: pretend)
      end

      private

      def owned_files(receipt)
        files = AgentTemplates.new(@intent, @name).files(@pack)
        return AgentReceipt.new(@files, @pack, @intent.namespace).preserve(receipt, files) if @files.exist?(receipt)

        files[receipt] = YAML.dump('schema' => 1, 'namespace' => @intent.namespace, 'paths' => files.keys)
        files
      end

      def check_ownership!(receipt)
        constants = %w[Agent Tool Schema].map { |suffix| "#{@intent.namespace}::#{@name.camelize}#{suffix}" }
        ConstantOwnership.new(@files.root, @pack).check!(constants, receipt: receipt)
      end

      def with_configuration(files, preview)
        return files if @files.exist?(CONFIG)

        if preview.all? { |action| action.start_with?('existing ') }
          raise InstallationError, "Restore missing #{CONFIG} before using this agent."
        end

        { CONFIG => "shared:\n  models: {}\n" }.merge(files)
      end

      def check_capability!
        return if @intent.data.dig('capabilities', 'ai', 'adapter') == 'ruby_llm'

        raise ConfigurationError, "Select capabilities.ai.adapter: ruby_llm in #{@pack}/foundry.yml first; " \
                                  "add gem 'ruby_llm', '~> 1.16.0' to the application bundle. No files changed."
      end
    end
  end
end
