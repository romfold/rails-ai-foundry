# frozen_string_literal: true

require 'pathname'
require_relative 'report'

module RailsAIFoundry
  module Support
    class FileSystem
      attr_reader :root, :report

      def initialize(root, report)
        @root = Pathname.new(root).realpath
        @report = report
      end

      def absolute(relative)
        root.join(relative)
      end

      def check(relative, type:, missing_rule: 'package.missing', optional: false)
        components = relative.split('/')
        if Pathname.new(relative).absolute? || components.intersect?(['..', '.', ''])
          return report.add('path.unsafe', relative, 'Use a canonical path inside the application.')
        end

        inspect_components(components, relative, type, missing_rule, optional)
      rescue SystemCallError => e
        unreadable(relative, e)
      end

      def read(relative)
        flags = File::RDONLY | File::NOFOLLOW
        File.open(absolute(relative), flags, &:read)
      rescue Errno::ELOOP
        report.add('path.unsafe', relative, 'Replace the symbolic link with a regular file.')
        nil
      rescue SystemCallError => e
        unreadable(relative, e)
        nil
      end

      def children(relative)
        Dir.children(absolute(relative)).sort
      rescue SystemCallError => e
        unreadable(relative, e)
        []
      end

      def unreadable(relative, error)
        report.add('io.unreadable', relative, "Cannot inspect this path (#{error.class}); check access permissions.")
      end

      private

      def correct_type?(stat, expected)
        expected == :directory ? stat.directory? : stat.file?
      end

      def inspect_components(components, relative, type, missing_rule, optional)
        components.each_index do |index|
          partial = components[0..index].join('/')
          stat = File.lstat(absolute(partial))
          return report.add('path.unsafe', partial, 'Replace the symbolic link with a real path.') if stat.symlink?

          expected = index == components.length - 1 ? type : :directory
          next if correct_type?(stat, expected)

          return report.add(missing_rule, partial, "Expected a regular #{expected}; correct the destination type.")
        end
        true
      rescue Errno::ENOENT
        return true if optional

        report_missing(relative, missing_rule)
      end

      def report_missing(relative, missing_rule)
        report.add(missing_rule, relative, 'Required path is missing; create it or correct the destination.')
      end
    end
  end
end
