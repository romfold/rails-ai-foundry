# frozen_string_literal: true

require_relative '../lib/benchmark_suite/shards'

module BenchmarkRepairs
  # Named offline repairs are separate from the first study's immutable fixtures.
  class SelectedPreparation
    SETS = %w[realtime-2026-09-21 realtime-guidance-2026-09-21 profile-realtime-2026-09-22].freeze

    def initialize(study, output, name)
      raise BenchmarkSuite::Failure, "Unknown repair set: #{name}" unless SETS.include?(name)

      @source = Pathname(study).realpath
      @output = output
      @name = name
      @fixtures = Pathname(__dir__).join('sets', name)
      @provenance = JSON.parse(@fixtures.join('provenance.json').read)
    end

    def call
      validate!
      root = BenchmarkSuite::Support.external_directory(@output)
      suite = root.join('upstream')
      suite.mkpath
      BenchmarkSuite::Shards.copy(@source.join('upstream'), suite, [@task])
      add_tests(suite.join('tasks', @task.name))
      copy_companion(root) if @companion
      copy_artifacts(root)
      BenchmarkSuite::Support.json(root.join('manifest.json'), manifest(root))
      root
    end

    def validate!
      validate_study!
      validate_task!
      validate_candidate!
      validate_companion! if @provenance['companion']
      @provenance.fetch('files').each do |relative, expected|
        path = @fixtures.join(relative)
        raise BenchmarkSuite::Failure, "Repair fixture mismatch: #{relative}" unless digest(path) == expected
      end
    end

    private

    def validate_companion!
      expected = @provenance.fetch('companion')
      suite = @source.join('foundry')
      @companion = Lemans::Config.load_file(suite).tasks.find { |task| task.name == expected.fetch('task') }
      unless @companion && @companion.digest == expected.fetch('task_digest')
        raise BenchmarkSuite::Failure, 'Selected repair companion task mismatch'
      end

      validate_companion_image!(suite, expected)
      validate_companion_candidate!(expected)
    end

    def validate_companion_image!(suite, expected)
      image = JSON.parse(suite.join('images.json').read).fetch(@companion.environment_image.name).fetch('id')
      raise BenchmarkSuite::Failure, 'Selected repair companion image mismatch' unless image == expected.fetch('image')
    end

    def validate_companion_candidate!(expected)
      candidates = @source.glob("results/*/*/#{@companion.name}__*/agent.patch")
      unless candidates.size == 1 && digest(candidates.first) == expected.fetch('original_sha256')
        raise BenchmarkSuite::Failure, 'Selected repair companion candidate mismatch'
      end

      @companion_original = candidates.first
    end

    def copy_companion(root)
      suite = root.join('foundry')
      suite.mkpath
      BenchmarkSuite::Shards.copy(@source.join('foundry'), suite, [@companion])
      FileUtils.cp(@companion_original, root.join('boundary-original.patch'))
    end

    def copy_artifacts(root)
      @fixtures.glob('*.patch').each { |path| FileUtils.cp(path, root) }
      FileUtils.cp(@original, root.join('original.patch'))
      FileUtils.cp(@fixtures.join('provenance.json'), root)
    end

    def validate_study!
      study = JSON.parse(@source.join('study.json').read)
      valid = study.fetch('foundry_revision') == @provenance.fetch('source_revision') &&
              study.fetch('upstream_revision') == @provenance.fetch('upstream_revision') &&
              digest(@source.join('study.json')) == @provenance.fetch('study_sha256')
      raise BenchmarkSuite::Failure, 'Selected repair study mismatch' unless valid
    end

    def validate_task!
      suite = @source.join('upstream')
      @task = Lemans::Config.load_file(suite).tasks.find { |task| task.name == @provenance.fetch('task') }
      unless @task && @task.digest == @provenance.fetch('task_digest')
        raise BenchmarkSuite::Failure, 'Selected repair task mismatch'
      end

      validate_image!(suite)
    end

    def validate_image!(suite)
      image = JSON.parse(suite.join('images.json').read).fetch(@task.environment_image.name).fetch('id')
      raise BenchmarkSuite::Failure, 'Selected repair image mismatch' unless image == @provenance.fetch('image')
    end

    def validate_candidate!
      candidates = @source.glob("results/*/*/#{@task.name}__*/agent.patch")
      unless candidates.size == 1 && digest(candidates.first) == @provenance.fetch('original_sha256')
        raise BenchmarkSuite::Failure, 'Selected repair candidate mismatch'
      end

      @original = candidates.first
    end

    def add_tests(task)
      task.join('tests').mkpath
      @fixtures.glob('*_test.rb').each { |path| FileUtils.cp(path, task.join('tests')) }
      task.join('bench.yml').write({ 'verifier' => {
        'command' => 'ruby -Itest -report-lemans /tests/realtime_test.rb'
      } }.to_yaml)
    end

    def manifest(root)
      { 'classification' => 'human-assisted regression evidence', 'repair_set' => @name,
        'study' => @source.to_s, 'provenance' => @provenance,
        'fixture_hashes' => BenchmarkSuite::Support.files(@fixtures),
        'files' => BenchmarkSuite::Support.files(root) }
    end

    def digest(path)
      path.file? && !path.symlink? ? Digest::SHA256.file(path).hexdigest : nil
    end
  end
end
