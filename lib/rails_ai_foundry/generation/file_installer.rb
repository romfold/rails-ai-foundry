# frozen_string_literal: true

require_relative '../errors'
require_relative '../support/file_system'

module RailsAIFoundry
  module Generation
    class FileInstaller
      def initialize(root)
        @report = Support::Report.new
        @file_system = Support::FileSystem.new(root, @report)
        reset_writes
      end

      private

      def reset_writes
        @created_files = []
        @created_directories = []
        @actions = []
      end

      def rollback_details(label: 'Preserved changed or inaccessible artifacts', include_empty: false)
        leftovers = rollback
        return '' if leftovers.empty? && !include_empty

        " #{label}: #{leftovers.join(', ')}."
      end

      def create_ancestors(path)
        return if path == '.'

        parts = path.split('/')
        parts.each_index { |index| create_directory(parts[0..index].join('/')) }
      end

      def create_directory(path)
        @current_path = path
        ensure_safe(path, :directory)
        return if File.directory?(@file_system.absolute(path))

        Dir.mkdir(@file_system.absolute(path))
        stat = File.lstat(@file_system.absolute(path))
        @created_directories << { path: path, inode: stat.ino, device: stat.dev }
      end

      def create_file(path, content)
        @current_path = path
        ensure_safe(path, :file)
        if File.exist?(@file_system.absolute(path))
          @actions << "existing #{path}"
          return
        end

        write_new_file(path, content)
      end

      def write_new_file(path, content, mode: nil)
        flags = File::WRONLY | File::CREAT | File::EXCL | File::NOFOLLOW
        File.open(@file_system.absolute(path), flags, 0o644) do |file|
          entry = file_identity(path, file.stat).merge(content: +'')
          @created_files << entry
          write_content(file, content, entry)
          file.chmod(mode) if mode
        end
        @actions << "created #{path}"
      end

      def ensure_safe(path, type)
        return if @file_system.check(path, type: type, optional: true)

        raise InstallationError, @report.diagnostics.join("\n")
      end

      def write_content(file, content, entry)
        until entry[:content].bytesize == content.bytesize
          remainder = content.byteslice(entry[:content].bytesize..-1)
          count = file.syswrite(remainder)
          entry[:content] << remainder.byteslice(0, count)
        end
      end

      def rollback
        leftovers = @created_files.reverse.filter_map { |entry| remove_created_file(entry) }
        leftovers.concat(@created_directories.reverse.filter_map { |entry| remove_created_directory(entry) })
        leftovers.uniq
      end

      def file_identity(path, stat)
        { path: path, inode: stat.ino, device: stat.dev }
      end

      def same_identity?(stat, entry)
        stat.ino == entry[:inode] && stat.dev == entry[:device]
      end

      def remove_created_directory(entry)
        return entry[:path] unless @file_system.check(entry[:path], type: :directory, optional: true)

        path = @file_system.absolute(entry[:path])
        stat = File.lstat(path)
        return entry[:path] unless stat.directory? && same_identity?(stat, entry)

        Dir.rmdir(path)
        nil
      rescue Errno::ENOENT
        nil
      rescue SystemCallError
        entry[:path]
      end

      def remove_created_file(entry)
        return entry[:path] unless @file_system.check(entry[:path], type: :file, optional: true)

        path = @file_system.absolute(entry[:path])
        stat = File.lstat(path)
        return entry[:path] unless stat.file? && same_identity?(stat, entry)

        content = File.open(path, File::RDONLY | File::NOFOLLOW, &:read)
        return entry[:path] unless content == entry[:content]

        File.unlink(path)
        nil
      rescue Errno::ENOENT
        nil
      rescue SystemCallError
        entry[:path]
      end
    end
  end
end
