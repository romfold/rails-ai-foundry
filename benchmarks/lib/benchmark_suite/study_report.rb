# frozen_string_literal: true

require_relative 'study_results'
require_relative 'openrouter_account'
require_relative 'evidence'

module BenchmarkSuite
  class StudyReport
    def self.call(root, output)
      new(root, output).call
    end

    def initialize(root, output, account: OpenrouterAccount.new)
      @root = Pathname(root).realpath
      @evidence = Evidence.new(output)
      @account = account
    end

    def call
      manifest = Study.load(@root)
      Study.validate!(@root, manifest)
      rows = StudyResults.new(@root).records
      result = assemble(rows)
      @evidence.json('report.json', result)
      @evidence.write('REPORT.md', markdown(result))
      result
    end

    private

    def assemble(rows)
      { 'model' => Study::MODEL, 'records' => rows, 'counts' => counts(rows),
        'suites' => rows.group_by { |row| row['suite'] }.transform_values { |group| counts(group) },
        'foundry_groups' => foundry_groups(rows), 'accounting' => accounting(rows),
        'manifest_sha256' => Digest::SHA256.file(@root.join('study.json')).hexdigest }
    end

    def counts(rows)
      rows.group_by { |row| row['status'] }.transform_values(&:size)
    end

    def foundry_groups(rows)
      foundry = rows.select { |row| row['suite'] == 'foundry' }
      foundry.group_by { |row| row['task'].split('-').last }.transform_values { |group| counts(group) }
    end

    def accounting(rows)
      costs = rows.filter_map { |row| row['native'] }.map { |native| native.dig('usage', 'cost_usd') }
      known = costs.all? { |value| value.is_a?(Numeric) && value.finite? && value >= 0 }
      { 'reported_cost' => known ? costs.sum : nil, 'provider' => provider_accounting }
    end

    def provider_accounting
      snapshot = @account.snapshot
      receipt = @root.join('preflights', "#{Study.attempts.first['id']}.json")
      initial = receipt.file? ? JSON.parse(receipt.read).dig('snapshot', 'account', 'usage') : nil
      usage = snapshot.dig('account', 'usage')
      { 'snapshot' => snapshot, 'study_usage_delta' => initial && usage && (usage - initial) }
    rescue Failure => e
      { 'snapshot' => nil, 'study_usage_delta' => nil, 'reason' => e.message }
    end

    def markdown(result)
      <<~MARKDOWN
        # Bounded OpenRouter study

        Model: #{Study::MODEL}. Counts: #{JSON.generate(result['counts'])}.

        Reported cost: #{result.dig('accounting', 'reported_cost').inspect} USD.
        Provider usage delta: #{result.dig('accounting', 'provider', 'study_usage_delta').inspect} USD.
        Unknown values are not zero. See report.json for native evidence, independent grades and resource stops.

        Smoke is excluded from measured results; upstream Rails and Foundry groups remain separate.
        One attempt per task/group is exploratory evidence, not a broad effectiveness claim.
        Unstarted, incomplete and failed attempts are retained. No automatic retries or additional trials.
      MARKDOWN
    end
  end
end
