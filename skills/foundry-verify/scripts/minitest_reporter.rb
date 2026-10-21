# frozen_string_literal: true

require 'json'
require 'pathname'
require 'minitest'
require_relative 'loaded_files'

module FoundrySkillVerification
  class Reporter < Minitest::AbstractReporter
    def initialize
      super
      @tests = []
    end

    def record(result)
      klass = Object.const_get(result.klass)
      @tests << { 'id' => "#{result.klass}##{result.name}", 'status' => status(result),
                  'assertions' => result.assertions, 'kind' => kind(klass),
                  'files' => files(result, klass), 'owned_files' => owned_files(result, klass) }
    end

    def report
      File.write(ENV.fetch('FOUNDRY_TEST_EVIDENCE'),
                 JSON.generate('tests' => @tests, 'loaded_files' => LoadedFiles.relative($LOADED_FEATURES)))
    end

    private

    def status(result)
      return 'skip' if result.skipped?

      result.passed? ? 'pass' : 'fail'
    end

    def kind(klass)
      ancestors = klass.ancestors.map(&:name)
      return 'browser' if ancestors.include?('ActionDispatch::SystemTestCase')
      return 'caller' if ancestors.include?('ActionDispatch::IntegrationTest')

      'unit'
    end

    def owned_files(result, klass)
      source = if klass.instance_method(result.name).owner == klass
                 result.source_location&.first
               else
                 Object.const_source_location(klass.name)&.first
               end
      source ? LoadedFiles.relative([source]) : []
    end

    def files(result, klass)
      [result.source_location&.first, Object.const_source_location(klass.name)&.first].compact.map do |path|
        Pathname(File.expand_path(path)).relative_path_from(Pathname(Dir.pwd)).to_s
      end.uniq
    end
  end
end

Minitest.define_singleton_method(:plugin_foundry_verification_init) do |_options|
  reporter << FoundrySkillVerification::Reporter.new
end
Minitest.extensions << 'foundry_verification'
