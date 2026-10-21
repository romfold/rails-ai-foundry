# frozen_string_literal: true

require 'yaml'
require_relative 'contexts'
require_relative 'component_templates'
require_relative 'constant_ownership'
require_relative 'namespace_inflections'
require_relative '../generation/scaffold_installer'

module RailsAIFoundry
  module Conventions
    class ComponentInstaller
      KINDS = %w[command operation query model entity value_object policy port repository controller job mailer
                 channel].freeze

      def initialize(root, name, context:, kind:)
        @root = root
        @pack, @intent = Contexts.new(root).find(context)
        unless KINDS.include?(kind) && /\A[a-z][a-z0-9_]*\z/.match?(name)
          raise ConfigurationError, 'Use a supported component kind and a snake_case name.'
        end

        @name = name
        @kind = kind
      end

      def call(pretend: false)
        template = ComponentTemplates.new(@intent, @name, @kind)
        path = "#{@pack}/#{template.path}"
        receipt = "#{@pack}/.foundry/components/#{@kind}/#{@name}.yml"
        ConstantOwnership.new(@root, @pack).check!([template.constant], receipt: receipt)
        files = { path => template.source,
                  receipt => YAML.dump('schema' => 1, 'path' => path, 'constant' => template.constant,
                                       'kind' => @kind) }
        NamespaceInflections.new(@root, @pack, @intent).install(files, receipt: receipt, pretend: pretend)
      end
    end
  end
end
