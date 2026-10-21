# frozen_string_literal: true

require_relative 'files'

module RailsAIFoundry
  module Conventions
    class PackageFiles
      ROOT_EXCLUSIONS = %w[vendor node_modules tmp log storage coverage].freeze

      attr_reader :packages

      def initialize(files, packages:)
        @files = files
        unless packages.is_a?(Array) && packages.all? { |path| valid_package?(path) }
          raise ConfigurationError, 'Checking requires application-relative upstream package paths.'
        end

        @packages = packages.map { |path| Pathname.new(path).cleanpath.to_s }.uniq.sort
        @packages.each { |path| @files.path(File.join(path, 'package.yml')) }
      end

      def owner(path)
        @packages.select { |pack| pack == '.' || path.start_with?("#{pack}/") }.max_by(&:length)
      end

      def select(directory, &selection)
        roots = (['.'] + @packages).uniq.filter_map do |pack|
          root = File.join(pack, directory).delete_prefix('./')
          root if (owner("#{root}/") || '.') == pack
        end
        roots.flat_map do |root|
          absolute = @files.path(root)
          next [] unless File.exist?(absolute)

          raise ConfigurationError, "Expected a source directory: #{root}" unless File.directory?(absolute)

          walk(root, &selection)
        end.uniq.sort
      end

      def owned_ruby(pack)
        raise ConfigurationError, 'Selected context is not an upstream package.' unless packages.include?(pack)

        walk_owned(pack).sort
      end

      private

      def walk_owned(directory)
        absolute = directory == '.' ? @files.root : @files.path(directory)
        Dir.children(absolute).sort.flat_map do |name|
          next [] if excluded_owned_entry?(directory, name)

          relative = File.join(directory, name).delete_prefix('./')
          next [] if packages.include?(relative)

          owned_entry(relative)
        end
      rescue SystemCallError
        raise ConfigurationError, "Cannot enumerate source directory: #{directory}"
      end

      def excluded_owned_entry?(directory, name)
        name.start_with?('.') || (directory == '.' && ROOT_EXCLUSIONS.include?(name))
      end

      def owned_entry(relative)
        absolute = @files.path(relative)
        return walk_owned(relative) if File.directory?(absolute)
        return relative.end_with?('.rb') ? [relative] : [] if File.file?(absolute)

        raise ConfigurationError, "Source entry disappeared or is not a regular file: #{relative}"
      end

      def valid_package?(path)
        path.is_a?(String) && !path.empty? && !path.start_with?('/') &&
          !path.include?("\0") && !path.split('/').include?('..')
      end

      def walk(directory, &selection)
        Dir.children(@files.path(directory)).sort.flat_map do |name|
          relative = "#{directory}/#{name}"
          absolute = @files.path(relative)
          next [] if @packages.include?(relative)

          if File.directory?(absolute)
            walk(relative, &selection)
          elsif File.file?(absolute)
            selection.call(relative) ? [relative] : []
          else
            raise ConfigurationError, "Source entry disappeared or is not a regular file: #{relative}"
          end
        end
      rescue SystemCallError
        raise ConfigurationError, "Cannot enumerate source directory: #{directory}"
      end
    end
  end
end
