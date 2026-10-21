# frozen_string_literal: true

require_relative 'support'

module BenchmarkSuite
  module Study
    MODEL = 'openrouter/openai/gpt-5.6-luna#medium'
    PROVIDER = 'openai'
    LIMIT = 7.0
    KEY_LIMIT = 20.0
    SUITES = %w[smoke foundry upstream].freeze
    FOUNDRY_TASKS = %w[boundary-extraction stale-embedding].product(%w[rails packs foundry]).map do |task, group|
      "#{task}-#{group}"
    end.freeze
    UPSTREAM_TASKS = %w[ar-tenant-isolation aj-enqueue-after-commit ft-comment-reaction-live-echo].freeze

    module_function

    def attempts
      pairs = [%w[smoke hello-world]] + FOUNDRY_TASKS.map { |name| ['foundry', name] } +
              UPSTREAM_TASKS.map { |name| ['upstream', name] }
      pairs.each_with_index.map do |(suite, task), index|
        { 'id' => format('%<index>02d-%<task>s', index: index, task: task), 'suite' => suite, 'task' => task,
          'cost_limit' => index.zero? ? 0.25 : 0.75 }
      end
    end

    def profile(smoke: false)
      { 'name' => 'miniswen', 'model' => MODEL, 'timeout' => smoke ? '3m' : '10m',
        'step_limit' => smoke ? 15 : 50, 'cost_limit' => smoke ? 0.25 : 0.75,
        'max_output_tokens' => 4096, 'exec_timeout' => 60,
        'environment' => { 'network' => { 'mode' => 'none' } } }
    end

    def load(root)
      JSON.parse(Pathname(root).join('study.json').read)
    end

    def validate!(root, manifest)
      raise Failure, 'Unexpected study matrix' unless manifest.fetch('attempts') == attempts
      raise Failure, 'Unexpected model or provider' unless manifest.values_at('model', 'provider') == [MODEL, PROVIDER]

      raise Failure, 'Missing frozen suites' unless manifest.fetch('frozen_files').keys.sort == SUITES.sort

      validate_files!(root, manifest.fetch('frozen_files'))
      raise Failure, 'Contributor implementation changed' unless manifest.fetch('tooling') == tooling
    end

    def validate_files!(root, files)
      files.each do |suite, hashes|
        raise Failure, "Frozen #{suite} inputs changed" unless hashes == Support.files(Pathname(root).join(suite))
      end
    end

    def tooling
      Support.files(ROOT.join('lib/benchmark_suite')).merge('suite' => Digest::SHA256.file(ROOT.join('suite')).hexdigest)
    end
  end
end
