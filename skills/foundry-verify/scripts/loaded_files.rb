# frozen_string_literal: true

require 'pathname'

module FoundrySkillVerification
  module LoadedFiles
    def self.relative(paths)
      root = File.realpath(Dir.pwd)
      paths.filter_map do |path|
        next unless File.file?(path)

        real = File.realpath(path)
        Pathname(real).relative_path_from(Pathname(root)).to_s if real.start_with?("#{root}/")
      end.uniq.sort
    end

    def self.verify(report, expected)
      loaded = report['loaded_files'] if report.is_a?(Hash)
      unless loaded.is_a?(Array) && loaded.all?(String)
        raise Failure, 'baseline: missing or malformed loaded-file evidence; review the installed helper upgrade.'
      end

      missing = expected - loaded
      return if missing.empty?

      raise Failure, "baseline: planned files were not loaded: #{missing.join(', ')}"
    end
  end
end
