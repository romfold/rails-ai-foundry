# frozen_string_literal: true

require_relative 'prompt_contract'
require_relative 'package_files'

module RailsAIFoundry
  module Conventions
    class PromptCheck
      LIMITATIONS = 'Explicit contract declarations and file existence only; constants, model aliases, template ' \
                    'semantics, authorization and evaluation outcomes are not resolved or executed. ' \
                    'Only application and upstream package app/prompts roots are inspected, including packages ' \
                    'without foundry.yml. Arbitrary template names require explicit contracts; ' \
                    'zero checks prove no AI behavior.'

      def initialize(root, contexts:, packages:)
        @files = Files.new(root)
        @contexts = contexts
        @packages = PackageFiles.new(@files, packages: packages)
      end

      def call
        paths = contract_paths
        diagnostics = paths.filter_map { |path| validate(path) }
        { 'success' => diagnostics.empty?, 'files_checked' => paths.size,
          'diagnostics' => diagnostics, 'limitations' => LIMITATIONS }
      end

      private

      def contract_paths
        paths = @packages.select('app/prompts') do |path|
          %w[contract.yml instructions.txt instructions.txt.erb].include?(File.basename(path))
        end
        paths.each { |path| inspect_selected!(path) }
        paths.map { |path| File.join(File.dirname(path), 'contract.yml') }.uniq.sort
      end

      def inspect_selected!(path)
        stat = File.open(@files.path(path), File::RDONLY | File::NOFOLLOW, &:stat)
        return if stat.file?

        raise ConfigurationError, "Expected a regular prompt file: #{path}."
      rescue SystemCallError
        raise ConfigurationError, "Cannot inspect selected prompt file: #{path}."
      end

      def validate(path)
        PromptContract.new(@files, @contexts, packages: @packages).call(path)
        nil
      rescue ConfigurationError => e
        { 'file' => path, 'line' => 1, 'rule' => 'prompt.contract', 'severity' => 'error',
          'certainty' => 'detected', 'message' => e.message }
      rescue SystemCallError
        { 'file' => path, 'line' => 1, 'rule' => 'prompt.contract', 'severity' => 'error',
          'certainty' => 'detected', 'message' => "Cannot inspect prompt contract: #{path}." }
      end
    end
  end
end
