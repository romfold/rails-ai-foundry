# frozen_string_literal: true

require 'json'
require 'open3'
require 'rbconfig'
require_relative 'application_config'
require_relative 'package_files'

module RailsAIFoundry
  module Conventions
    class Contexts
      DISCOVER = 'require "packs-specification"; require "json"; puts JSON.generate(Packs.all.map(&:name))'

      attr_reader :files

      def initialize(root)
        @files = ApplicationConfig.new(root).files
      end

      def all(packages: nil)
        validate_roots!
        (packages || upstream_paths).each_with_object({}) do |pack, contexts|
          files.path("#{pack}/package.yml")
          validate_intent_location!(pack)
          contexts[pack] = Intent.load(files.root, pack) if files.exist?("#{pack}/foundry.yml")
        end
      end

      def find(namespace, packages: nil)
        matches = all(packages: packages).select do |path, intent|
          intent.namespace == namespace || path == namespace || File.basename(path) == namespace
        end
        return matches.first if matches.size == 1

        raise ConfigurationError, "Expected one context for #{namespace.inspect}; found #{matches.size}."
      end

      def packages
        validate_roots!
        upstream_paths
      end

      private

      def validate_intent_location!(pack)
        misplaced = "#{pack}/config/foundry.yml"
        return if pack == '.' || !files.exist?(misplaced)

        raise ConfigurationError, "Misplaced context configuration: #{misplaced}. " \
                                  "Use #{pack}/foundry.yml beside package.yml; " \
                                  'keep workflow settings in root config/foundry.yml. No files were changed.'
      end

      def upstream_paths
        output, error, status = Open3.capture3(RbConfig.ruby, '-e', DISCOVER, chdir: files.root)
        raise ConfigurationError, "Upstream pack discovery failed: #{error}" unless status.success?

        PackageFiles.new(files, packages: JSON.parse(output)).packages
      rescue JSON::ParserError
        raise ConfigurationError, 'Invalid upstream package discovery output; expected a JSON array of relative paths.'
      end

      def validate_roots!
        configuration = files.yaml('packs.yml', optional: true)
        return unless configuration.key?('pack_paths')

        paths = configuration['pack_paths']
        valid = paths.is_a?(Array) && paths.all? { |path| relative_glob?(path) }
        return if valid

        raise ConfigurationError, 'packs.yml pack_paths must be an array of application-relative glob strings.'
      end

      def relative_glob?(path)
        path.is_a?(String) && !path.empty? && !path.start_with?('/') && !path.include?('..')
      end
    end
  end
end
