# frozen_string_literal: true

ENV['BUNDLE_GEMFILE'] = File.expand_path('../Gemfile', __dir__)
require 'bundler/setup'
require_relative '../lib/benchmark_suite/shards'

module BenchmarkRepairs
  # Derived offline inputs only. Historical study files are never modified.
  class Preparation
    TASK = 'ft-comment-reaction-live-echo'
    FIXTURES = Pathname(__dir__).join('fixtures')

    def self.call(study, output)
      source = Pathname(study).realpath
      root = BenchmarkSuite::Support.external_directory(output)
      upstream = source.join('upstream')
      task = realtime_task(upstream)

      suite = root.join('upstream')
      suite.mkpath
      BenchmarkSuite::Shards.copy(upstream, suite, [task])
      add_tests(suite.join('tasks', TASK))
      copy_patches(source, root)
      manifest(source, root, task)
      root
    end

    def self.realtime_task(upstream)
      task = Lemans::Config.load_file(upstream).tasks.find { |item| item.name == TASK }
      raise BenchmarkSuite::Failure, 'Missing pinned realtime task' unless task

      expected = JSON.parse(FIXTURES.join('provenance.json').read).fetch('candidates').fetch(TASK)
      raise BenchmarkSuite::Failure, 'Pinned task digest mismatch' unless task.digest == expected.fetch('task_digest')

      task
    end

    def self.manifest(source, root, task)
      BenchmarkSuite::Support.json(root.join('manifest.json'), {
                                     'classification' => 'human-assisted regression evidence',
                                     'study' => source.to_s, 'upstream_revision' => BenchmarkSuite::UPSTREAM_REVISION,
                                     'task_digest' => task.digest, 'fixture_hashes' => BenchmarkSuite::Support.files(FIXTURES),
                                     'files' => BenchmarkSuite::Support.files(root)
                                   })
    end

    def self.add_tests(task)
      task.join('tests').mkpath
      FIXTURES.glob('*_test.rb').each { |path| FileUtils.cp(path, task.join('tests')) }
      task.join('bench.yml').write({ 'verifier' => {
        'command' => 'ruby -Itest -report-lemans /tests/realtime_test.rb'
      } }.to_yaml)
    end

    def self.copy_patches(source, root)
      FileUtils.cp(FIXTURES.join('provenance.json'), root)
      FIXTURES.glob('*.patch').each { |path| FileUtils.cp(path, root) }
      copy_originals(source, root)
      copy_faults(root)
    end

    def self.copy_originals(source, root)
      %w[boundary-extraction-foundry ft-comment-reaction-live-echo].each do |task|
        patches = source.glob("results/*/*/#{task}__*/agent.patch")
        raise BenchmarkSuite::Failure, "Expected one saved candidate: #{task}" unless patches.size == 1

        validate_original(task, patches.first)
        FileUtils.cp(patches.first, root.join("#{task}-original.patch"))
      end
    end

    def self.validate_original(task, patch)
      provenance = JSON.parse(FIXTURES.join('provenance.json').read)
      expected = provenance.fetch('candidates').fetch(task).fetch('original_sha256')
      return if Digest::SHA256.file(patch).hexdigest == expected

      raise BenchmarkSuite::Failure, "Saved candidate hash mismatch: #{task}"
    end

    def self.copy_faults(root)
      %w[missing-delivery duplicate-echo composer-replacement guarded-composer-replacement].each do |variant|
        root.join("#{variant}-complete.patch").binwrite(
          FIXTURES.join('realtime-complete.patch').binread + FIXTURES.join("#{variant}.patch").binread
        )
      end
    end
  end
end

if $PROGRAM_NAME == __FILE__
  abort 'Usage: ruby benchmarks/repairs/prepare.rb FROZEN_STUDY NEW_OUTPUT [REPAIR_SET]' unless (2..3).cover?(ARGV.size)
  if ARGV.size == 3
    require_relative 'selected_preparation'
    puts BenchmarkRepairs::SelectedPreparation.new(*ARGV).call
  else
    puts BenchmarkRepairs::Preparation.call(*ARGV)
  end
end
