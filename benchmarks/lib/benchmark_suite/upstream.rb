# frozen_string_literal: true

require_relative 'support'
require_relative 'prerequisites'
require_relative 'local_overrides'

module BenchmarkSuite
  class Upstream
    def self.prepare(destination, source: nil)
      new(destination).prepare(source)
    end

    def initialize(destination)
      @root = Support.external_directory(destination)
    end

    def prepare(source)
      source = checkout(source)
      export(source)
      configure
      Prerequisites.prepare(@root)
      LocalOverrides.prepare(@root)
      config = Lemans::Config.load_file(@root)
      tasks = config.tasks
      raise Failure, "Expected 42 tasks, found #{tasks.size}" unless tasks.size == 42

      manifest(tasks)
      @root
    end

    private

    def manifest(tasks)
      records = tasks.map do |task|
        { 'name' => task.name, 'category' => category(task.name), 'files' => Support.files(task.dir) }
      end
      Support.json(@root.join('manifest.json'), {
                     'suite' => 'upstream', 'revision' => UPSTREAM_REVISION,
                     'lemans_revision' => LEMANS_REVISION, 'tasks' => records,
                     'source_files' => Support.files(@root),
                     'overrides' => 'Local Docker; offline oracle/nop; no model; not leaderboard reproduction'
                   })
    end

    def checkout(source)
      unless source
        source = @root.join('checkout')
        Support.run('git', 'init', '-q', source.to_s)
        Support.run('git', '-C', source.to_s, 'fetch', '--depth', '1', 'https://github.com/rails/ai-evals.git',
                    UPSTREAM_REVISION)
        Support.run('git', '-C', source.to_s, 'checkout', '--detach', 'FETCH_HEAD')
      end
      source = Pathname(source).realpath
      revision = Support.run('git', '-C', source.to_s, 'rev-parse', 'HEAD')['output'].strip
      raise Failure, 'AI-evals revision mismatch' unless revision == UPSTREAM_REVISION

      source
    end

    def export(source)
      archive = @root.join('source.tar')
      Support.run('git', '-C', source.to_s, 'archive', '--format=tar', "--output=#{archive}", UPSTREAM_REVISION,
                  *export_entries(source))
      Support.run('tar', '-xf', archive.to_s, '-C', @root.to_s)
      archive.delete
      FileUtils.rm_rf(@root.join('checkout')) if source == @root.join('checkout')
      record_source
    end

    def record_source
      Support.json(@root.join('upstream-files.json'), Support.files(@root))
      FileUtils.cp(@root.join('bench.yml'), @root.join('upstream-bench.yml'))
    end

    def export_entries(source)
      entries = %w[bench.yml tasks docker]
      tracked = Support.run('git', '-C', source.to_s, 'ls-tree', '--name-only',
                            UPSTREAM_REVISION)['output'].lines.map(&:strip)
      entries.concat(tracked.grep(/\A(?:LICENSE|NOTICE|COPYING|README)/))
    end

    def configure
      data = YAML.safe_load_file(@root.join('bench.yml'))
      data['environment']['backend'] = 'docker'
      data['environment']['network'] = { 'mode' => 'none' }
      data['agent'] = {
        'name' => 'nop', 'model' => 'offline-controls', 'timeout' => '10m',
        'environment' => { 'network' => { 'mode' => 'none' } }
      }
      @root.join('bench.yml').write(data.to_yaml)
    end

    def category(name)
      return 'smoke' if name == 'hello-world'

      name.start_with?('ft-') ? 'feature' : 'atomic'
    end
  end
end
