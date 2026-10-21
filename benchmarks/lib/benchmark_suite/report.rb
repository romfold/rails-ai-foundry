# frozen_string_literal: true

require_relative 'evidence'

module BenchmarkSuite
  class Report
    def self.call(workspace, output, summaries)
      new(workspace, output, summaries).call
    end

    def initialize(workspace, output, summaries)
      @root = Pathname(workspace).realpath
      @evidence = Evidence.new(output)
      @summaries = summaries.map { |path| Pathname(path).realpath }
      @tasks = Lemans::Config.load_file(@root).tasks
    end

    def call
      records = @summaries.flat_map { |path| JSON.parse(path.read).fetch('records') }
      result = assemble(records)
      @evidence.json('report.json', result)
      @evidence.write('REPORT.md', markdown(result))
      result
    end

    private

    def assemble(records)
      pairs = records.map { |row| [row.fetch('task'), row.fetch('agent', 'unknown')] }
      result = coverage(records, pairs, expected_pairs)
      result['categories'] = categories(records)
      result['summary_files'] = @summaries.to_h { |path| [path.to_s, Digest::SHA256.file(path).hexdigest] }
      result
    end

    def categories(records)
      records.group_by { |row| row.fetch('category', 'unknown') }.transform_values { |rows| counts(rows) }
    end

    def expected_pairs
      controls = @tasks.all? { |task| task.metadata.key?('expected_pass') }
      @tasks.flat_map { |task| (controls ? ['oracle'] : %w[oracle nop]).map { |agent| [task.name, agent] } }
    end

    def coverage(records, pairs, expected)
      missing = expected - pairs
      extra = pairs - expected
      duplicates = pairs.tally.select { |_pair, count| count > 1 }.keys
      { 'accepted' => missing.empty? && extra.empty? && duplicates.empty? && records.all? do |row|
        row['control_passed']
      end,
        'missing' => missing, 'extra' => extra, 'duplicates' => duplicates, 'counts' => counts(records) }
    end

    def counts(records)
      statuses = records.group_by { |row| row.fetch('status') }.transform_values(&:size)
      { 'attempted' => records.size, 'valid' => statuses.fetch('passed', 0) + statuses.fetch('failed', 0),
        'behavior_passed' => statuses.fetch('passed', 0), 'behavior_failed' => statuses.fetch('failed', 0),
        'invalid_protocol' => statuses.fetch('invalid_protocol', 0),
        'infrastructure_error' => statuses.fetch('infrastructure_error', 0),
        'disagreement' => statuses.fetch('disagreement', 0),
        'controls_passed' => records.count { |row| row['control_passed'] } }
    end

    def markdown(result)
      <<~MARKDOWN
        # Offline benchmark controls

        Acceptance: **#{result['accepted'] ? 'passed' : 'incomplete or failed'}**.

        #{JSON.pretty_generate(result['counts'])}

        See report.json for complete coverage, category counts and input hashes.
        Smoke checks are separate from atomic and feature results. These are local
        oracle/no-op controls, not model evaluations or a reproduction of the Rails leaderboard.
        Historical Cursor pilot results remain unchanged. No new coding-agent trials ran.
      MARKDOWN
    end
  end
end
