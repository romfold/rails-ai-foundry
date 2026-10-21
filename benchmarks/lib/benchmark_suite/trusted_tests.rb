# frozen_string_literal: true

require 'tmpdir'
require_relative 'support'

module BenchmarkSuite
  class TrustedTests
    attr_reader :directory

    def initialize(task)
      @directory = Pathname(Dir.mktmpdir('foundry-trusted-tests-'))
      File.chmod(0o755, @directory)
      entries_for(task).each { |source, relative| copy(source, relative) }
    end

    def entries_for(task)
      entries = task.verifier.files + task.test_files
      assets = Lemans::Trial::Verifier::ASSETS.children.select(&:file?)
      entries += assets.map { |path| [path, path.basename.to_s] }
      entries.concat(baseline_plugins) if task.verifier.preverify
      entries
    end

    def close
      FileUtils.remove_entry(directory)
    end

    private

    def baseline_plugins
      %w[foundry_baseline.rb minitest/foundry_baseline_plugin.rb].map do |relative|
        [ROOT.join('verification', relative), relative]
      end
    end

    def copy(source, relative)
      path = Pathname(relative)
      raise Failure, 'Unsafe verifier path' if path.absolute? || path.each_filename.include?('..')

      target = directory.join(path)
      raise Failure, "Verifier collision: #{relative}" if target.exist?

      target.dirname.mkpath
      FileUtils.cp(source, target)
    end
  end
end
