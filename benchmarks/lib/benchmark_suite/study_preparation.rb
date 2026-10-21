# frozen_string_literal: true

require_relative 'study'
require_relative 'foundry'
require_relative 'upstream'
require_relative 'shards'
require_relative 'images'
require_relative 'dependencies'

module BenchmarkSuite
  class StudyPreparation
    def self.call(output)
      new(output).call
    end

    def initialize(output)
      @root = Support.external_directory(output)
    end

    def call
      sources = prepare_sources
      Study::SUITES.each { |suite| prepare_suite(suite, sources) }
      Support.json(@root.join('study.json'), manifest)
      @root.join('COMMANDS.md').write(commands)
      @root
    end

    private

    def prepare_sources
      directory = @root.join('sources')
      directory.mkpath
      { 'foundry' => Foundry.prepare(directory.join('foundry')),
        'upstream' => Upstream.prepare(directory.join('upstream'),
                                       source: ENV.fetch('BENCHMARK_UPSTREAM_CHECKOUT', nil)) }
    end

    def prepare_suite(suite, sources)
      source = sources.fetch(suite == 'foundry' ? 'foundry' : 'upstream')
      tasks = selected_tasks(source, suite)
      root = Support.external_directory(@root.join(suite))
      Shards.copy(source, root, tasks)
      configure(root, suite)
      Images.build(root)
      Dependencies.capture(root, @root.join('dependencies', suite))
      record_tasks(root, suite)
    end

    def selected_tasks(source, suite)
      names = Study.attempts.select { |row| row['suite'] == suite }.map { |row| row['task'] }
      tasks = Lemans::Config.load_file(source).tasks.select { |task| names.include?(task.name) }
      raise Failure, 'Missing selected tasks' unless tasks.size == names.size

      tasks
    end

    def configure(root, suite)
      config = YAML.safe_load_file(root.join('bench.yml'))
      config['agent'] = Study.profile(smoke: suite == 'smoke')
      root.join('bench.yml').write(config.to_yaml)
      Support.json(root.join('live-study.json'), { 'model' => Study::MODEL, 'provider' => Study::PROVIDER })
    end

    def record_tasks(root, suite)
      tasks = Lemans::Config.load_file(root).tasks
      validate_profiles(tasks, suite)
      Support.json(root.join('study-tasks.json'), tasks.to_h do |task|
        [task.name, { 'task_digest' => task.digest, 'profile_digest' => task.config.digest }]
      end)
    end

    def validate_profiles(tasks, suite)
      expected = Lemans::Config::Agent.from_config(Study.profile(smoke: suite == 'smoke')).to_h
      raise Failure, 'Task overrides study limits' unless tasks.all? { |task| task.config.agent.to_h == expected }
    end

    def manifest
      { 'version' => 1, 'model' => Study::MODEL, 'provider' => Study::PROVIDER,
        'allocation' => Study::LIMIT, 'key_limit' => Study::KEY_LIMIT, 'attempts' => Study.attempts,
        'lemans_revision' => LEMANS_REVISION, 'upstream_revision' => UPSTREAM_REVISION,
        'foundry_revision' => Support.run('git', 'rev-parse', 'HEAD', directory: REPOSITORY)['output'].strip,
        'tooling' => Study.tooling,
        'frozen_files' => Study::SUITES.to_h { |suite| [suite, Support.files(@root.join(suite))] } }
    end

    def commands
      intro = "# Ordered native commands\n\nRun in the shell holding OPENROUTER_API_KEY. " \
              "Stop on any preflight failure. Run each block once; no automatic retries.\n\n"
      intro + Study.attempts.map { |row| command_block(row) }.join("\n")
    end

    def command_block(row)
      root = Shellwords.escape(@root.to_s)
      suite = "#{root}/#{row['suite']}"
      id = row.fetch('id')
      <<~MARKDOWN
        ## #{id}
        ```sh
        benchmarks/suite study-preflight #{root} #{row['task']} #{root}/preflight-output/#{id} &&
        LEMANS_PROVIDER_ORDER=openai bundle exec lemans run --bench #{suite} --task #{row['task']} --attempts 1 --concurrency 1 --runs-dir #{root}/results/#{id}
        benchmarks/suite replay #{suite} #{root}/results/#{id} #{root}/verification/#{id}
        benchmarks/suite study-report #{root} #{root}/reports/#{id}
        ```
      MARKDOWN
    end
  end
end
