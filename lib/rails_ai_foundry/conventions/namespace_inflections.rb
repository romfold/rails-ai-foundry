# frozen_string_literal: true

require 'digest'
require 'yaml'
require_relative 'contexts'
require_relative '../generation/scaffold_installer'

module RailsAIFoundry
  module Conventions
    class NamespaceInflections
      def initialize(root, pack, intent)
        @files = Files.new(root)
        @pack = pack
        @intent = intent
        @installer = Generation::ScaffoldInstaller.new(@files.root)
      end

      def install(primary, receipt:, pretend: false)
        check_mappings!
        preview = @installer.install_files(primary, receipt: receipt, pretend: true)
        supplemental = supplemental_files
        unless supplement?(supplemental, preview)
          return @installer.install_files(primary, receipt: receipt, pretend: pretend)
        end

        install_combined(primary, preview, supplemental, pretend)
      end

      private

      def supplement?(supplemental, preview)
        return false if supplemental.empty?
        return true unless existing?(preview)

        supplemental.keys.any? { |path| @files.exist?(path) }
      end

      def install_combined(primary, preview, supplemental, pretend)
        extra = @installer.install_files(supplemental, receipt: inflection_receipt, pretend: true)
        pending = (existing?(preview) ? {} : primary).merge(existing?(extra) ? {} : supplemental)
        actions = (existing?(preview) ? preview : []) + (existing?(extra) ? extra : [])
        actions + @installer.install_files(pending, pretend: pretend)
      end

      def existing?(actions)
        actions.all? { |action| action.start_with?('existing ') }
      end

      def check_mappings!
        owners = {}
        Contexts.new(@files.root).all.merge(@pack => @intent).each do |pack, intent|
          segments(intent).each do |basename, constant|
            owner = owners[basename]
            if owner && owner.first != constant
              raise ConfigurationError, "Conflicting namespace inflections for #{basename}: " \
                                        "#{owner.first} (#{owner.last}) and #{constant} (#{pack})."
            end
            owners[basename] = [constant, pack]
          end
        end
      end

      def segments(intent)
        intent.namespace.split('::').map { |segment| [segment.underscore, segment] }
      end

      def overrides
        segments(@intent).reject { |basename, constant| basename.split('_').map(&:capitalize).join == constant }.to_h
      end

      def inflection_receipt
        "#{@pack}/.foundry/inflections.yml"
      end

      def supplemental_files
        selections = overrides
        path = "config/initializers/foundry_inflections_#{Digest::SHA256.hexdigest(@pack)}.rb"
        return {} if selections.empty? && !@files.exist?(inflection_receipt) && !@files.exist?(path)

        { path => source(selections),
          inflection_receipt => YAML.dump('schema' => 1, 'namespace' => @intent.namespace,
                                          'path' => path, 'overrides' => selections) }
      end

      def source(selections)
        pairs = selections.map { |basename, constant| "'#{basename}' => '#{constant}'" }.join(', ')
        <<~RUBY
          # frozen_string_literal: true

          # Application-owned namespace loading for #{@pack.inspect}; preserve when upgrading tooling.
          Rails.autoloaders.each do |loader|
            loader.inflector.inflect(#{pairs})
          end
        RUBY
      end
    end
  end
end
