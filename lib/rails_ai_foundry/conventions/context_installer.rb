# frozen_string_literal: true

require 'yaml'
require 'json'
require 'open3'
require 'tmpdir'
require 'rbconfig'
require 'active_support/inflector'
require_relative 'contexts'
require_relative 'application_config'
require_relative 'namespace_inflections'
require_relative '../generation/scaffold_installer'

module RailsAIFoundry
  module Conventions
    class ContextInstaller
      CREATE = 'require "packs"; Packs.create_pack!(pack_name: ARGV.fetch(0), ' \
               'enforce_dependencies: true, enforce_privacy: true, enforce_layers: false)'

      def initialize(root, name, path: nil, **intent)
        @files = Files.new(root)
        unless /\A[a-z][a-z0-9_]*\z/.match?(name)
          raise ConfigurationError, 'Context name must be snake_case, such as billing.'
        end

        @path = path || "packs/#{name}"
        if Pathname.new(@path).absolute? || @path.split('/').intersect?(%w[. ..])
          raise ConfigurationError, 'Use an application-relative context path without . or .. segments.'
        end

        @files.path(@path)
        @intent = context_intent(name, intent)
      end

      def call(pretend: false)
        @files.application!
        check_namespace!
        files = generated_files
        NamespaceInflections.new(@files.root, @path, @intent).install(files, receipt: receipt, pretend: pretend)
      end

      private

      def context_intent(name, options)
        defaults = ApplicationConfig.new(@files.root).defaults
        overrides = options.transform_keys(&:to_s).compact
        if overrides['patterns'].is_a?(Hash)
          overrides['patterns'] = defaults.fetch('patterns', {}).merge(overrides['patterns'])
        end
        Intent.new(defaults.merge('namespace' => name.camelize).merge(overrides))
      end

      def check_namespace!
        collision = Contexts.new(@files.root).all.any? do |path, intent|
          path != @path && intent.namespace == @intent.namespace
        end
        return unless collision

        raise ConfigurationError, "Context namespace #{@intent.namespace} is already owned by another pack."
      end

      def receipt
        "#{@path}/.foundry/context.yml"
      end

      def generated_files
        files = upstream_files
        files['packwerk.yml'] = packwerk_configuration unless @files.exist?('packwerk.yml')
        files["#{@path}/foundry.yml"] = YAML.dump(@intent.data)
        files["#{@path}/app/public/#{@intent.namespace.underscore}/.keep"] = ''
        files[receipt] = YAML.dump('schema' => 1, 'intent' => @intent.data, 'path' => @path)
        files
      end

      def upstream_files
        Dir.mktmpdir('foundry-pack-') do |stage|
          copy_configuration(stage)
          output, error, status = Open3.capture3(RbConfig.ruby, '-e', CREATE, @path, chdir: stage)
          raise InstallationError, "packs create failed: #{output}\n#{error}" unless status.success?

          staged = Files.new(stage)
          Dir.glob("#{@path}/**/*", File::FNM_DOTMATCH, base: stage).each_with_object({}) do |path, result|
            result[path] = staged.read(path) if File.file?(staged.path(path))
          end
        end
      end

      def copy_configuration(stage)
        source = @files.read('packs.yml')
        File.write(File.join(stage, 'packs.yml'), source) if source
        File.write(File.join(stage, 'packwerk.yml'), packwerk_configuration)
      end

      def packwerk_configuration
        return YAML.dump('require' => ['packwerk-extensions']) unless @files.exist?('packwerk.yml')

        configuration = @files.yaml('packwerk.yml')
        requires = configuration.fetch('require', [])
        unless requires.is_a?(Array) && requires.include?('packwerk-extensions')
          raise ConfigurationError, 'Add packwerk-extensions to packwerk.yml require before creating a private context.'
        end

        @files.read('packwerk.yml')
      end
    end
  end
end
