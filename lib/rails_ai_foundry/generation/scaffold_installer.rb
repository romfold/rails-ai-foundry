# frozen_string_literal: true

require_relative '../errors'
require_relative 'file_installer'

module RailsAIFoundry
  module Generation
    class ScaffoldInstaller < FileInstaller
      def install_files(files, receipt: nil, pretend: false, **hooks)
        reset_writes
        preview = preview_files(files, receipt, pretend, hooks[:preflighted])
        return preview if preview

        execute_files(files, hooks)
      rescue SystemCallError, InstallationError => e
        raise if hooks[:wrap_failure] == false

        details = rollback_details
        raise InstallationError, "#{@current_path}: scaffold installation failed: #{e.message}.#{details}"
      end

      private

      def preview_files(files, receipt, pretend, preflighted)
        return files.keys.map { |path| "existing #{path}" } if !preflighted && existing_scaffold?(files, receipt)
        return unless pretend

        files.keys.map { |path| "would create #{path}" }
      end

      def execute_files(files, hooks)
        hooks[:before_write]&.call
        write_files(files)
        hooks[:publish]&.call
        @actions
      end

      def existing_scaffold?(files, receipt)
        files.each_key { |path| ensure_safe(path, :file) }
        existing = files.keys.select { |path| File.exist?(@file_system.absolute(path)) }
        return false if existing.empty?
        return true if receipt && existing.size == files.size && @file_system.read(receipt) == files.fetch(receipt)

        raise InstallationError, 'Conflicting or partial scaffold; review existing files and generation receipt.'
      end

      def write_files(files)
        files.each do |path, content|
          create_ancestors(File.dirname(path))
          @current_path = path
          ensure_safe(path, :file)
          write_new_file(path, content)
        end
      end
    end
  end
end
