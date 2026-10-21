# frozen_string_literal: true

require_relative 'selection'
require_relative 'upstream'
require_relative '../generation/scaffold_installer'

module RailsAIFoundry
  module Workflows
    class Setup
      JOURNAL = '.foundry/workflow-setup-in-progress'

      def initialize(root, stdout: $stdout, tool_root: root)
        @selection = Selection.new(root)
        @files = @selection.files
        @stdout = stdout
        @tool_root = tool_root
      end

      def call(specs: nil, greenfield: false, agent: 'codex', pretend: false)
        @files.application!
        check_interruption!
        name = @selection.resolve(explicit: specs, greenfield: greenfield)
        artifacts = prepare(name, agent)
        preflight!(artifacts)
        actions = artifacts.keys.map { |path| "#{pretend ? 'would create' : 'created'} #{path}" }
        actions << "#{pretend ? 'would select' : 'selected'} #{name} in #{Selection::CONFIG}"
        install(artifacts, name) unless pretend
        actions
      end

      def doctor(specs: nil, greenfield: false, agent: 'codex')
        @files.application!
        check_interruption!
        name = @selection.resolve(explicit: specs, greenfield: greenfield)
        Upstream.new(@tool_root, name, agent: agent, stdout: @stdout).check! unless name == 'none'
        state = @selection.initialized?(name) ? 'initialized' : 'initialization required'
        ["workflow: #{name} (#{state})", "application: #{@files.root}"]
      end

      private

      def check_interruption!
        return unless @files.exist?(JOURNAL)

        raise InstallationError, "Previous workflow setup was interrupted; inspect #{JOURNAL} and listed artifacts " \
                                 'before removing the journal and retrying. No files were changed.'
      end

      def prepare(name, agent)
        return {} if @selection.initialized?(name)

        if @selection.detected.include?(name)
          raise InstallationError, "Incomplete #{name} installation; repair it with upstream tooling before setup."
        end

        Upstream.new(@tool_root, name, agent: agent, stdout: @stdout).artifacts
      end

      def preflight!(artifacts)
        artifacts.each_key do |path|
          if @files.exist?(path)
            raise InstallationError,
                  "Workflow artifact already exists: #{path}; preserve or relocate it explicitly."
          end
        end
      end

      def install(artifacts, name)
        return publish_selection(name) if artifacts.empty?

        contents = artifacts.transform_values { |entry| entry.fetch(:content) }
        contents = { JOURNAL => YAML.dump('workflow' => name, 'files' => contents.keys) }.merge(contents)
        Generation::ScaffoldInstaller.new(@files.root).install_files(contents, publish: lambda {
          restore_modes(artifacts)
          publish_selection(name)
        })
        File.unlink(@files.path(JOURNAL))
      end

      def restore_modes(artifacts)
        artifacts.each { |path, entry| File.chmod(entry.fetch(:mode), @files.path(path)) }
      end

      def publish_selection(name)
        unless @files.read(Selection::CONFIG) == @selection.source
          raise InstallationError, "#{Selection::CONFIG} changed after preview; rerun setup."
        end

        return if @selection.configuration.dig('workflow', 'specs') == name

        @files.publish(Selection::CONFIG, @selection.content(name), expected: @selection.source)
      end
    end
  end
end
