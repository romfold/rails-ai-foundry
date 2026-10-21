# frozen_string_literal: true

require 'bundler'
require 'digest'
require 'open3'
require 'rbconfig'
require_relative 'files'
require_relative '../support/command_text'

module RailsAIFoundry
  module Conventions
    class BoundaryCheck
      def initialize(root)
        @files = Files.new(root)
      end

      def call
        preflight!
        before = baselines
        commands = []
        %w[validate check].each do |action|
          commands << execute(action)
          break unless commands.last.fetch('exit_status').zero?
        end
        unchanged = before == baselines
        { 'backend' => 'packwerk', 'environment' => 'test', 'commands' => commands,
          'limitations' => 'Upstream checks only; review fully resolved baselines separately. No pks parity verified.',
          'baselines_unchanged' => unchanged,
          'success' => unchanged && commands.all? { |command| command.fetch('exit_status').zero? } }
      end

      private

      def preflight!
        @files.application!
        return if @files.exist?('Gemfile.lock') && @files.exist?('packwerk.yml')

        raise ConfigurationError, 'Boundary checks require packwerk.yml and an installed, locked application bundle.'
      end

      def baselines
        Dir.glob('**/package_todo.yml', File::FNM_DOTMATCH, base: @files.root).sort.to_h do |path|
          content = @files.read(path)
          raise ConfigurationError, "Accepted debt file disappeared during verification: #{path}" unless content

          [path, Digest::SHA256.hexdigest(content)]
        end
      end

      def execute(action)
        argv = [RbConfig.ruby, '-S', 'bundle', 'exec', RbConfig.ruby, '-rstringio', '-S', 'packwerk', action]
        environment = { 'BUNDLE_GEMFILE' => @files.path('Gemfile'), 'BUNDLE_FROZEN' => 'true',
                        'RAILS_ENV' => 'test', 'RACK_ENV' => 'test', 'BUNDLE_VERSION' => Bundler::VERSION }
        output, error, status = Bundler.with_unbundled_env do
          Open3.capture3(environment, *argv, chdir: @files.root)
        end
        { 'argv' => argv, 'stdout' => Support::CommandText.normalize(output),
          'stderr' => Support::CommandText.normalize(error), 'exit_status' => status.exitstatus || 1 }
      end
    end
  end
end
