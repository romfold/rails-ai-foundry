# frozen_string_literal: true

require 'open3'
require 'shellwords'
require 'tmpdir'
require_relative '../conventions/files'

module RailsAIFoundry
  module Workflows
    # Development-time CLI integration; applications do not load a workflow runtime.
    class Upstream
      VERSIONS = { 'spec_kit' => '1.0.0', 'openspec' => '1.12.0' }.freeze
      INSTALL = {
        'spec_kit' => 'Install Python >= 3.11, then uv tool install ' \
                      'specify-cli --from git+https://github.com/github/spec-kit.git@v1.0.0 ' \
                      '(pipx install with the same URL is also supported).',
        'openspec' => 'Install Node >= 20.19, then npm install --save-dev --save-exact @fission-ai/openspec@1.12.0.'
      }.freeze

      def initialize(root, name, agent: 'codex', stdout: $stdout)
        @root = root
        @name = name
        @agent = agent
        @stdout = stdout
        raise ConfigurationError, '--agent must be codex, claude or cursor.' unless %w[codex claude
                                                                                       cursor].include?(agent)
      end

      def check!
        arguments = @name == 'spec_kit' ? ['version'] : ['--version']
        output = execute([executable, *arguments], @root)
        version = output.b.gsub(/\e\[[\d;]*m/, '')[/\b\d+\.\d+\.\d+(?:[-+][\w.-]+)?\b/]
        return if version == VERSIONS.fetch(@name)

        raise ConfigurationError, "Expected #{@name} #{VERSIONS.fetch(@name)}, found #{version.inspect}. #{instruction}"
      rescue Errno::ENOENT
        raise ConfigurationError, "Missing #{@name} tooling. #{instruction}"
      end

      def artifacts
        check!
        Dir.mktmpdir('foundry-workflow-') do |stage|
          execute(command, stage)
          collect(stage)
        end
      end

      private

      def collect(stage)
        staged = Conventions::Files.new(stage)
        Dir.glob('**/*', File::FNM_DOTMATCH, base: stage).sort.each_with_object({}) do |relative, files|
          next if relative == '.'

          path = staged.path(relative)
          next if File.directory?(path)

          raise InstallationError, "Upstream generated a non-regular file: #{relative}" unless File.file?(path)

          files[relative] = { content: File.binread(path), mode: File.stat(path).mode & 0o777 }
        end
      end

      def instruction
        INSTALL.fetch(@name)
      end

      def executable
        return 'specify' if @name == 'spec_kit'

        local = File.join(@root, 'node_modules/.bin/openspec')
        File.executable?(local) ? local : 'openspec'
      end

      def command
        if @name == 'spec_kit'
          agent = @agent == 'cursor' ? 'cursor-agent' : @agent
          [executable, 'init', '--here', '--integration', agent, '--ignore-agent-tools', '--non-interactive']
        else
          [executable, 'init', '.', '--tools', @agent, '--profile', 'core', '--no-animation']
        end
      end

      def execute(command, directory)
        @stdout.puts "Running: #{Shellwords.join(command)} (in #{directory})"
        output, error, status = Open3.capture3({ 'OPENSPEC_TELEMETRY' => '0' }, *command, chdir: directory)
        @stdout.puts output unless output.empty?
        @stdout.puts error unless error.empty?
        unless status.success?
          raise InstallationError,
                "#{@name} exited #{status.exitstatus}; setup was not installed. #{instruction}"
        end

        output
      end
    end
  end
end
