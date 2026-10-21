# frozen_string_literal: true

require 'pathname'
require 'fileutils'
require 'tempfile'
require_relative '../errors'
require_relative '../support/safe_yaml'

module RailsAIFoundry
  module Conventions
    class Files
      attr_reader :root

      def initialize(root)
        @root = File.realpath(root)
      end

      def path(relative)
        candidate = File.expand_path(relative, root)
        unless candidate.start_with?("#{root}/")
          raise ConfigurationError, 'Paths must stay within the consuming application.'
        end

        current = Pathname.new(candidate)
        until current.to_s == root
          raise ConfigurationError, "Symbolic links are not supported: #{relative}" if current.symlink?

          current = current.parent
        end
        candidate
      end

      def exist?(relative)
        File.exist?(path(relative))
      end

      def read(relative)
        File.binread(path(relative)) if exist?(relative)
      end

      def yaml(relative, optional: false)
        source = read(relative)
        return {} if source.nil? && optional
        raise ConfigurationError, "Missing #{relative}." unless source

        parse_yaml(relative, source)
      end

      def parse_yaml(relative, source)
        data = Support::SafeYaml.load(source)
        raise ConfigurationError, "#{relative} must contain a mapping." unless data.is_a?(Hash)

        data
      rescue Support::SafeYaml::Invalid => e
        raise ConfigurationError, "#{relative}: #{e.message}"
      end

      def publish(relative, content, expected: nil)
        destination = path(relative)
        FileUtils.mkdir_p(File.dirname(destination))
        Tempfile.create(['.foundry-', '.tmp'], File.dirname(destination)) do |file|
          file.binmode
          file.write(content)
          file.flush
          prepare_replacement(relative, file.path, expected)
          File.rename(file.path, path(relative))
        end
      end

      def application!
        return if exist?('config/application.rb') && exist?('Gemfile')

        raise ConfigurationError,
              'Run this command in a consuming Rails application (Gemfile and config/application.rb).'
      end

      private

      def prepare_replacement(relative, temporary, expected)
        raise InstallationError, "#{relative} changed after preview; rerun setup." unless read(relative) == expected

        destination = path(relative)
        File.chmod(File.stat(destination).mode & 0o777, temporary) if File.exist?(destination)
      end
    end
  end
end
