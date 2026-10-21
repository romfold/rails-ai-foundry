# frozen_string_literal: true

require 'open3'
require 'shellwords'
require 'rbconfig'
require 'bundler'
require_relative '../workflows/setup'
require_relative '../generation/skill_installer'

module RailsAIFoundry
  module Conventions
    class NewApplication
      TEMPLATE = File.expand_path('../templates/native_application.rb', __dir__)
      JOURNAL = '.foundry/new-in-progress'

      def initialize(root, stdout: $stdout)
        @files = Files.new(root)
        @stdout = stdout
      end

      def call(name, specs: 'spec-kit', agent: 'codex', pretend: false, **rails_options)
        destination = destination(name)
        workflow = workflow(specs, agent)
        command = rails_command(destination, rails_options)
        @stdout.puts "#{pretend ? 'Would run' : 'Running'}: #{command.shelljoin}"
        return ["Would initialize #{workflow} and Foundry skills in #{destination}"] if pretend

        create(destination, command, workflow, agent)
      end

      private

      def destination(name)
        unless /\A[a-z][a-z0-9_]*\z/.match?(name)
          raise ConfigurationError, 'Use a new snake_case application name in the selected parent directory.'
        end

        path = @files.path(name)
        raise InstallationError, "Destination already exists: #{path}; use foundry adopt or setup." if File.exist?(path)

        path
      end

      def workflow(specs, agent)
        name = specs == 'spec-kit' ? 'spec_kit' : specs
        unless Workflows::Selection::VALUES.include?(name)
          raise ConfigurationError, '--specs must be spec-kit, openspec or none.'
        end

        upstream = Workflows::Upstream.new(@files.root, name, agent: agent, stdout: @stdout)
        upstream.check! unless name == 'none'
        name
      end

      def rails_command(destination, options)
        database = options.fetch(:database, 'postgresql')
        unless %w[postgresql sqlite3].include?(database)
          raise ConfigurationError, '--database must be postgresql or sqlite3.'
        end

        version = Gem::Specification.find_by_name('railties').version
        command = [RbConfig.ruby, '-e', 'gem "railties", ARGV.shift; load ARGV.shift', version.to_s,
                   Gem.bin_path('railties', 'rails', version), 'new', destination, '--no-rc', "--database=#{database}",
                   '--template', TEMPLATE]
        command.push('--skip-solid', '--skip-kamal', '--skip-thruster') if version >= Gem::Version.new('8.0')
        %i[skip_git skip_dev_gems].each { |key| command << "--#{key.to_s.tr('_', '-')}" if options[key] }
        command
      end

      def create(destination, command, workflow, agent)
        Dir.mkdir(destination)
        files = Files.new(destination)
        files.publish(JOURNAL,
                      "Rails creation and Foundry setup are unfinished. Inspect this application before retrying.\n")
        execute(command)
        verify_creation(files)
        messages = install_guidance(destination, workflow, agent)
        File.unlink(files.path(JOURNAL))
        messages << 'Application and Foundry setup completed. Run bin/rails db:prepare before starting the app or jobs.'
        messages
      rescue InstallationError, ConfigurationError, SystemCallError => e
        raise InstallationError, "#{e.message}\nCreation incomplete at #{destination}; files were preserved. " \
                                 "Inspect #{JOURNAL} before manual recovery."
      end

      def install_guidance(destination, workflow, agent)
        setup = Workflows::Setup.new(destination, stdout: @stdout, tool_root: @files.root)
        messages = setup.call(specs: workflow, greenfield: true, agent: agent)
        target = agent == 'codex' ? 'agents' : agent
        messages.concat(Generation::SkillInstaller.new(destination, target: target).call)
      end

      def execute(command)
        output, error, status = Bundler.with_unbundled_env do
          Open3.capture3(*command, chdir: @files.root)
        end
        @stdout.puts output unless output.empty?
        @stdout.puts error unless error.empty?
        raise InstallationError, "Rails new exited #{status.exitstatus}." unless status.success?
      end

      def verify_creation(files)
        required = %w[Gemfile.lock .foundry/native-application.yml bin/jobs config/importmap.rb
                      app/javascript/controllers/index.js]
        missing = required.reject { |path| files.exist?(path) }
        return if missing.empty?

        raise InstallationError, "Rails integration is incomplete; missing: #{missing.join(', ')}."
      end
    end
  end
end
