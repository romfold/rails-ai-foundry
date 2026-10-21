# frozen_string_literal: true

require_relative 'audit_snapshot'

module RailsAIFoundry
  module Conventions
    module Debt
      def self.identities(root)
        snapshot = AuditSnapshot.new(root)
        snapshot.paths.select { |path| File.basename(path) == 'package_todo.yml' }.flat_map do |path|
          read_file(snapshot, path)
        end.uniq.sort
      end

      def self.read_file(snapshot, path)
        source = snapshot.read(path)
        return [] if empty?(source)

        snapshot.files.parse_yaml(path, source).flat_map do |target, constants|
          unless target.is_a?(String) && constants.is_a?(Hash)
            raise ConfigurationError, "Invalid debt target in #{path}"
          end

          constants.flat_map { |constant, details| expand(File.dirname(path), target, constant, details, path) }
        end
      end

      def self.expand(package, target, constant, details, path)
        unless constant.is_a?(String) && valid_details?(details)
          raise ConfigurationError, "Invalid debt identity in #{path}"
        end

        details['violations'].product(details['files']).map do |type, source|
          [package, target, constant, type, source]
        end
      end

      def self.empty?(source)
        source.lines.all? { |line| line.strip.empty? || line.lstrip.start_with?('#') }
      end

      def self.valid_details?(details)
        details.is_a?(Hash) && %w[violations files].all? { |key| strings?(details[key]) }
      end

      def self.strings?(value)
        value.is_a?(Array) && value.all? { |item| item.is_a?(String) && !item.empty? }
      end
      private_class_method :expand, :read_file, :valid_details?, :strings?, :empty?
    end
  end
end
