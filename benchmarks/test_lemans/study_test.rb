# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'
require_relative '../lib/benchmark_suite/study_preparation'
require_relative '../lib/benchmark_suite/study_preflight'
require_relative '../lib/benchmark_suite/study_report'
require_relative 'study_protocol_tests'

class StudyTest < Minitest::Test
  include StudyProtocolTests

  Study = BenchmarkSuite::Study
  Account = Data.define(:data) do
    def snapshot = data
  end

  def snapshot
    { 'account' => { 'limit' => Study::KEY_LIMIT, 'limit_reset' => nil, 'limit_remaining' => 8, 'usage' => 0 },
      'endpoint' => { 'tag' => 'openai', 'status' => 0, 'supported_parameters' => %w[tools reasoning],
                      'pricing' => { 'prompt' => '0.0000002', 'completion' => '0.0000012' } } }
  end

  def setup
    @directory = Pathname(Dir.mktmpdir('foundry-study-test-'))
    @root = @directory.join('study')
    @root.mkpath
    prepare_suites
    manifest = { 'attempts' => Study.attempts, 'model' => Study::MODEL, 'provider' => Study::PROVIDER,
                 'tooling' => Study.tooling,
                 'frozen_files' => Study::SUITES.to_h { |suite| [suite, BenchmarkSuite::Support.files(@root.join(suite))] } }
    BenchmarkSuite::Support.json(@root.join('study.json'), manifest)
  end

  def prepare_suites
    Study::SUITES.each do |suite|
      directory = @root.join(suite)
      directory.mkpath
      tasks = Study.attempts.select { |row| row['suite'] == suite }.to_h do |row|
        [row['task'], { 'task_digest' => row['task'], 'profile_digest' => 'profile' }]
      end
      BenchmarkSuite::Support.json(directory.join('study-tasks.json'), tasks)
    end
  end

  def teardown
    FileUtils.remove_entry(@directory)
  end

  def preflight(task = 'hello-world', name: 'preflight', data: snapshot)
    BenchmarkSuite::StudyPreflight.new(@root, task, @directory.join(name), account: Account.new(data)).call
  end

  def native(row, outcome: 'completed')
    { 'task' => row['task'], 'agent' => 'miniswen', 'model' => Study::MODEL,
      'task_digest' => row['task'], 'profile_digest' => 'profile', 'reward' => 1,
      'usage' => { 'cost_usd' => 0.01 }, 'outcome' => { 'name' => outcome, 'scored' => true } }
  end

  def record(row = Study.attempts.first, status: 'passed', independent: nil, outcome: 'completed')
    directory = @root.join('results', row['id'], 'trial')
    directory.mkpath
    BenchmarkSuite::Support.json(directory.join('result.json'), native(row, outcome: outcome))
    verification = @root.join('verification', row['id'])
    verification.mkpath
    BenchmarkSuite::Support.json(verification.join('summary.json'), {
                                   'native_files' => BenchmarkSuite::Support.files(directory.parent),
                                   'records' => [{ 'task' => row['task'], 'status' => status,
                                                   'independent' => independent }]
                                 })
    directory
  end

  def test_exact_matrix_and_resource_profiles
    assert_equal 10, Study.attempts.size
    assert_equal(7.0, Study.attempts.sum { |row| row['cost_limit'] })
    assert_equal 6, Study::FOUNDRY_TASKS.size
  end

  def test_resource_profiles
    assert_equal [15, 50], [Study.profile(smoke: true)['step_limit'], Study.profile['step_limit']]
    timeouts = [Study.profile(smoke: true), Study.profile].map do |profile|
      Lemans::Config::Agent.from_config(profile).timeout
    end
    assert_equal [180, 600], timeouts
    assert_equal 4096, Study.profile['max_output_tokens']
  end

  def test_single_receipt_and_unchanged_input_gate
    assert preflight['eligible']
    assert_raises(BenchmarkSuite::Failure) { preflight(name: 'duplicate') }
    @root.join('foundry/new.rb').write('changed')
    assert_raises(BenchmarkSuite::Failure) { preflight(Study.attempts[1]['task'], name: 'changed') }
  end

  def test_future_attempt_cannot_skip_smoke
    assert_raises(BenchmarkSuite::Failure) { preflight(Study.attempts[1]['task']) }
  end

  def test_verified_smoke_unlocks_one_next_attempt
    preflight
    record
    result = preflight(Study.attempts[1]['task'], name: 'second')
    assert result['eligible']
    assert_equal 0.01, result.dig('accounting', 'reported_cost')
  end

  def test_failed_smoke_stops_study
    preflight
    record(status: 'failed')
    assert_raises(BenchmarkSuite::Failure) { preflight(Study.attempts[1]['task'], name: 'second') }
  end

  def test_key_limits_and_accounting_fail_closed
    [{ 'limit' => nil }, { 'limit_reset' => 'daily' }, { 'usage' => nil },
     { 'limit_remaining' => 0.5 }].each_with_index do |change, index|
      data = snapshot
      data['account'].merge!(change)
      assert_raises(BenchmarkSuite::Failure) { preflight(name: "invalid-#{index}", data: data) }
    end
    refute @root.join('preflights', "#{Study.attempts.first['id']}.json").exist?
  end

  def test_unavailable_provider_and_missing_capabilities_fail_closed
    [{ 'tag' => 'azure' }, { 'status' => -1 }, { 'supported_parameters' => [] },
     { 'pricing' => {} }].each_with_index do |change, index|
      data = snapshot
      data['endpoint'].merge!(change)
      assert_raises(BenchmarkSuite::Failure) { preflight(name: "provider-#{index}", data: data) }
    end
  end

  def test_total_spend_and_unknown_previous_cost_stop
    previous = [{ 'native' => { 'usage' => { 'cost_usd' => 6.9 } } }]
    budget = BenchmarkSuite::StudyBudget
    assert_raises(BenchmarkSuite::Failure) do
      budget.validate!(snapshot, previous: previous, first: nil, attempt: Study.attempts[1])
    end
    previous.first['native']['usage']['cost_usd'] = nil
    assert_raises(BenchmarkSuite::Failure) do
      budget.validate!(snapshot, previous: previous, first: nil, attempt: Study.attempts[1])
    end
  end

  def test_missing_key_is_detected_without_http
    account = BenchmarkSuite::OpenrouterAccount.new(key: '')
    assert_raises(BenchmarkSuite::Failure) { account.snapshot }
  end

  def test_changed_native_artifacts_and_duplicate_trials_are_invalid
    directory = record
    directory.join('unexpected.patch').write('tampered')
    assert_equal 'infrastructure_error', BenchmarkSuite::StudyResults.new(@root).records.first['status']
    FileUtils.cp_r(directory, directory.parent.join('duplicate'))
    assert_equal 'infrastructure_error', BenchmarkSuite::StudyResults.new(@root).records.first['status']
  end

  def test_unstarted_report_does_not_claim_a_model_run
    report = BenchmarkSuite::StudyReport.new(@root, @directory.join('report'), account: Account.new(snapshot)).call
    assert_equal({ 'unstarted' => 10 }, report['counts'])
    assert_nil report.dig('accounting', 'provider', 'study_usage_delta')
    assert_equal({ 'unstarted' => 6 }, report.dig('suites', 'foundry'))
  end

  def test_malformed_native_shapes_are_infrastructure_failures
    directory = record
    [nil, [], 'invalid'].each do |value|
      directory.join('result.json').write(JSON.generate(value))
      assert_equal 'infrastructure_error', BenchmarkSuite::StudyResults.new(@root).records.first['status']
    end
  end

  def test_malformed_verification_shapes_are_infrastructure_failures
    directory = record
    summary = @root.join('verification', Study.attempts.first['id'], 'summary.json')
    [nil, [], { 'native_files' => BenchmarkSuite::Support.files(directory.parent), 'records' => nil }].each do |value|
      summary.write(JSON.generate(value))
      assert_equal 'infrastructure_error', BenchmarkSuite::StudyResults.new(@root).records.first['status']
    end
  end

  def test_resource_stops_remain_incomplete_after_diagnostic_pass
    row = native(Study.attempts.first, outcome: 'cost_ceiling_reached')
    assert_equal 'incomplete', BenchmarkSuite::StudyOutcome.status(row, { 'status' => 'passed' }, 'passed')
    row['outcome']['name'] = 'accounting_error'
    assert_equal 'infrastructure_error', BenchmarkSuite::StudyOutcome.status(row, { 'status' => 'passed' }, 'passed')
    assert_equal 'invalid_protocol',
                 BenchmarkSuite::StudyOutcome.status(row, { 'status' => 'invalid_protocol' }, 'passed')
  end
end
