# frozen_string_literal: true

require 'active_support/inflector'
require_relative '../generation/ruby_source'

module RailsAIFoundry
  module Conventions
    class ComponentTemplates
      DELIVERY = { 'controller' => %w[controllers ApplicationController],
                   'job' => %w[jobs ApplicationJob], 'mailer' => %w[mailers ApplicationMailer],
                   'channel' => ['channels', 'ApplicationCable::Channel'] }.freeze
      PURE = %w[entity value_object policy].freeze

      def initialize(intent, name, kind)
        @intent = intent
        @name = name
        @kind = kind
      end

      def path
        "app/#{directory}/#{@intent.namespace.underscore}/#{category_path}#{filename}.rb"
      end

      def source
        body, superclass, requirement = definition
        ruby = Generation::RubySource.definition(constant, body, superclass: superclass)
        "# frozen_string_literal: true\n\n#{requirement}#{ruby}\n"
      end

      def constant
        category = category_path.empty? ? '' : "#{category_path.delete_suffix('/').camelize}::"
        "#{@intent.namespace}::#{category}#{filename.camelize}"
      end

      private

      def filename
        DELIVERY.key?(@kind) ? "#{@name}_#{@kind}" : @name
      end

      def directory
        return DELIVERY.fetch(@kind).first if DELIVERY.key?(@kind)
        return 'models' if @kind == 'model'
        return domain_directory if @intent.profile == 'domain'

        @intent.profile == 'rails_native' && @kind == 'command' ? 'operations' : @kind.pluralize
      end

      def domain_directory
        return 'infrastructure' if @kind == 'repository'

        PURE.include?(@kind) ? 'domain' : 'application'
      end

      def category_path
        return '' unless @intent.profile == 'domain' && !DELIVERY.key?(@kind) && @kind != 'model'

        "#{@kind.pluralize}/"
      end

      def definition
        return command if @kind == 'command'
        return operation if @kind == 'operation'
        return ['', DELIVERY.fetch(@kind).last, ''] if DELIVERY.key?(@kind)
        if @kind == 'model'
          return ["self.table_name = '#{@intent.namespace.underscore.tr('/', '_')}_#{@name.pluralize}'",
                  'ApplicationRecord', '']
        end

        ["def call(*)\n  raise NotImplementedError, 'Implement #{@intent.namespace} behavior and tests'\nend", nil, '']
      end

      def operation
        body = <<~RUBY
          skip_prepending

          def call(input)
            steps { step perform(input) }
          end

          private

          def perform(_input)
            raise NotImplementedError, 'Implement behavior and return a native Success or Failure'
          end
        RUBY
        [body, 'Dry::Operation', "require 'dry/operation'\n\n"]
      end

      def command
        body = <<~RUBY
          skip_prepending

          def call(input)
            result = nil
            ApplicationRecord.transaction(requires_new: true) do
              result = steps { step perform(input) }
              raise ActiveRecord::Rollback if result.failure?
            end
            result
          end

          private

          def perform(_input)
            raise NotImplementedError, 'Implement local writes; keep external I/O outside the transaction'
          end
        RUBY
        [body, 'Dry::Operation', "require 'dry/operation'\n\n"]
      end
    end
  end
end
