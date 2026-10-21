# frozen_string_literal: true

require 'digest'
require 'find'
require 'json'
require 'tmpdir'
require_relative 'files'

module RailsAIFoundry
  module Conventions
    class AuditSnapshot
      POLICY_VERSION = 2
      EXCLUDED = %w[.git .bundle .agents .claude .codex .cursor .specify node_modules vendor tmp log storage
                    coverage .next .env credentials master.key].freeze

      attr_reader :files

      def initialize(root)
        @files = Files.new(root)
      end

      def inventory
        paths.to_h { |path| [path, Digest::SHA256.hexdigest(read(path))] }
      end

      def paths
        paths = []
        Find.find(files.root, ignore_error: false) do |absolute|
          next if absolute == files.root

          relative = included_path(absolute)
          paths << relative if relative
        end
        paths.sort
      rescue SystemCallError
        raise ConfigurationError, 'Cannot enumerate audit inputs; check permissions and retry.'
      end

      def read(relative)
        files.read(relative) || raise(ConfigurationError, "Missing audit input: #{relative}")
      rescue SystemCallError
        raise ConfigurationError, "Cannot read audit input: #{relative}"
      end

      def fingerprint(inputs = inventory)
        Digest::SHA256.hexdigest(JSON.generate([POLICY_VERSION, inputs]))
      end

      def copy(expected: inventory)
        Dir.mktmpdir('foundry-audit-') do |directory|
          copy_files(directory, expected)
          unless expected == self.class.new(directory).inventory && expected == inventory
            raise ConfigurationError, 'Audit inputs changed or copy is incomplete; retry audit.'
          end

          yield directory, expected
        end
      rescue SystemCallError
        raise ConfigurationError, 'Cannot copy audit inputs; check permissions and available disk space.'
      end

      private

      def copy_files(directory, inputs)
        inputs.each_key do |relative|
          target = File.join(directory, relative)
          FileUtils.mkdir_p(File.dirname(target))
          FileUtils.cp(files.path(relative), target)
        end
      end

      def included_path(absolute)
        relative = Pathname.new(absolute).relative_path_from(Pathname.new(files.root)).to_s
        if relative == '.foundry/skill-upgrades' || excluded?(File.basename(relative))
          Find.prune if File.directory?(absolute)
          return
        end
        files.path(relative)
        return if File.directory?(absolute)
        raise ConfigurationError, "Audit input must be a regular file: #{relative}" unless File.file?(absolute)

        relative
      end

      def excluded?(name)
        EXCLUDED.include?(name) || name.start_with?('.env.') || name.end_with?('.enc', '.sqlite3', '.db')
      end
    end
  end
end
