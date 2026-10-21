# frozen_string_literal: true

require_relative 'foundry_references'
require_relative 'files'
require_relative 'architecture_source_rules'
require_relative 'package_sources'

module RailsAIFoundry
  module Conventions
    class SourceCheck
      LIMITATIONS = 'Application app/ and all upstream package app/ Ruby files, including packages without sidecars. ' \
                    "Files outside app/ are excluded. #{FoundryReferences::LIMITATIONS} " \
                    "#{ArchitectureSourceRules::LIMITATIONS}".freeze

      def initialize(root, contexts:, packages:)
        @files = Files.new(root)
        @contexts = contexts
        @inventory = PackageSources.new(@files, packages: packages)
      end

      def call
        paths = @inventory.paths
        diagnostics = inspect_sources(paths)
        { 'success' => diagnostics.none? { |item| item['severity'] == 'error' }, 'files_checked' => paths.size,
          'diagnostics' => diagnostics, 'limitations' => LIMITATIONS }
      end

      private

      def inspect_sources(paths)
        sources = paths.to_h do |path|
          [path, read_source(path)]
        end
        models = sources.values.flat_map { |source| RubySyntax.models(Ripper.sexp(source)) }
        rules = ArchitectureSourceRules.new(contexts: @contexts, models: models)
        sources.flat_map do |path, source|
          FoundryReferences.new.call(path, source) + rules.call(path, source, context: context_for(path))
        end
      end

      def context_for(path)
        owner = @inventory.owner(path)
        @contexts.find { |item| Pathname.new(item.fetch('path')).cleanpath.to_s == owner }
      end

      def read_source(path)
        @files.read(path) || raise(ConfigurationError, "Source disappeared during verification: #{path}")
      rescue SystemCallError
        raise ConfigurationError, "Cannot read source: #{path}"
      end
    end
  end
end
