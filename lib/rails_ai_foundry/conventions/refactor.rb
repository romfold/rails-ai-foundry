# frozen_string_literal: true

require_relative 'foundry_references'
require_relative 'contexts'
require_relative 'architecture_source_rules'

module RailsAIFoundry
  module Conventions
    class Refactor
      def initialize(root)
        @contexts = Contexts.new(root)
      end

      def call(context:, profile: nil)
        @inventory = PackageFiles.new(@contexts.files, packages: @contexts.packages)
        pack, intent = @contexts.find(context, packages: @inventory.packages)
        target = profile || intent.profile
        Intent.validate_profile!(target)
        evidence = findings(pack, intent)
        { 'complete' => evidence.none? { |item| item['rule'] == 'source.syntax' },
          'limitations' => 'Selected package non-hidden Ruby and model declarations only, including tests and lib; ' \
                           'Nested packages excluded; root skips vendor, node_modules, tmp, log, storage, coverage. ' \
                           "#{FoundryReferences::LIMITATIONS} #{ArchitectureSourceRules::LIMITATIONS}",
          'context' => pack, 'configuration' => "#{pack}/foundry.yml".delete_prefix('./'), 'profile' => intent.profile,
          'proposed_profile' => target, 'findings' => evidence, 'next_steps' => next_steps(intent, target) }
      end

      private

      def findings(pack, intent)
        sources = context_sources(pack)
        rules = architecture_rules(pack, intent, sources)
        context = { 'path' => pack, 'profile' => intent.profile, 'namespace' => intent.namespace }
        sources.flat_map do |path, source|
          diagnostics = FoundryReferences.new.call(path, source) + rules.call(path, source, context: context)
          diagnostics.map { |item| item.merge('path' => item.fetch('file'), 'advice' => item.fetch('message')) }
        end
      end

      def architecture_rules(pack, intent, sources)
        models = sources.values.flat_map { |source| RubySyntax.models(Ripper.sexp(source)) }
        context = { 'path' => pack, 'profile' => intent.profile, 'namespace' => intent.namespace }
        ArchitectureSourceRules.new(contexts: [context], models: models)
      end

      def context_sources(pack)
        @inventory.owned_ruby(pack).to_h do |path|
          [path, read_source(path)]
        end
      end

      def read_source(path)
        @contexts.files.read(path) || raise(ConfigurationError, "Source disappeared during assessment: #{path}")
      rescue SystemCallError
        raise ConfigurationError, "Cannot read source: #{path}"
      end

      def next_steps(intent, target)
        steps = ['Characterize current behavior before moving code; preserve package.yml dependencies and privacy.',
                 'Review detected syntax; constant resolution, reachability and dynamic calls remain unproven.',
                 'Run owning-context tests and isolated Packwerk checks; do not regenerate accepted debt.']
        if target != intent.profile
          steps.unshift("Propose profile: #{target}; keep installed foundry.yml authoritative until acceptance.",
                        'Review namespaces and call sites; changing a profile does not migrate code or data.')
        end
        steps
      end
    end
  end
end
