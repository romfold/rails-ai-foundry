# frozen_string_literal: true

require_relative 'verification'
require_relative 'study_outcome'

module BenchmarkSuite
  class Replay
    def self.call(workspace, runs, output)
      new(workspace, runs, output).call
    end

    def initialize(workspace, runs, output)
      @workspace = Pathname(workspace).realpath
      @runs = Pathname(runs).realpath
      @output = Support.external_directory(output)
      @live = @workspace.join('live-study.json').file?
      @tasks = Lemans::Config.load_file(@workspace).tasks.to_h { |task| [task.name, task] }
      @source_hashes = Support.files(ROOT.join('lib/benchmark_suite'))
    end

    def call
      before = Support.files(@runs)
      records = @runs.glob('**/result.json').sort.map { |path| replay(path) }
      raise Failure, 'No native results found' if records.empty?
      raise Failure, 'Native evidence changed during replay' unless before == Support.files(@runs)

      Support.json(@output.join('summary.json'), summary(records, before))
      records
    end

    private

    def summary(records, before)
      { 'records' => records, 'counts' => records.group_by { |row| row['status'] }.transform_values(&:size),
        'native_files' => before, 'expected_tasks' => @tasks.keys.sort,
        'missing_tasks' => @tasks.keys - records.map { |row| row['task'] },
        'verification_sources' => @source_hashes }
    end

    def control_passed?(task, native, independent, status)
      expected = task.metadata.fetch('expected_pass', native['agent'] == 'oracle')
      return false unless status == (expected ? 'passed' : 'failed')
      return true if expected || !task.metadata['group']

      independent.dig('foundry', 'behavioral') == 'failed' && independent['assertion_failure']
    end

    def replay(path)
      native = JSON.parse(path.read)
      task = @tasks.fetch(native.fetch('task'))
      unless matching_task?(native, task)
        return { 'task' => task.name, 'agent' => native.fetch('agent'), 'category' => category(task),
                 'native_result' => path.to_s, 'status' => 'infrastructure_error',
                 'control_passed' => false, 'reason' => 'task_or_profile_digest_mismatch' }
      end

      independent = verify_candidate(task, path)
      record(task, native, independent, path)
    rescue StandardError => e
      replay_failure(path, native, e)
    end

    def matching_task?(native, task)
      native.fetch('task_digest') == task.digest && native.fetch('profile_digest') == task.config.digest
    end

    def replay_failure(path, native, error)
      native = {} unless native.is_a?(Hash)
      { 'task' => native.fetch('task', 'unknown'), 'agent' => native.fetch('agent', 'unknown'),
        'category' => 'unknown', 'native_result' => path.to_s, 'status' => 'infrastructure_error',
        'control_passed' => false, 'error_class' => error.class.name, 'reason' => error.message }
    end

    def verify_candidate(task, path)
      relative = path.dirname.relative_path_from(@runs).to_s.tr('/', '_')
      output = @output.join(relative)
      result = Verification.new(@workspace, task.name, path.dirname.join('agent.patch'), output).call
      result['assertion_failure'] = assertion_failure?(output)
      result
    end

    def assertion_failure?(output)
      checks = output.join('checks.json')
      checks.file? && JSON.parse(checks.read).fetch('checks', {}).value?('fail')
    end

    def record(task, native, independent, path)
      initial = native_status(native)
      status = independent.fetch('status')
      status = 'disagreement' if %w[passed failed].include?(status) && status != initial
      status = StudyOutcome.status(native, independent, status) if @live
      { 'task' => task.name, 'native_outcome' => native.dig('outcome', 'name'), 'native_result' => path.to_s,
        'native_status' => initial,
        'independent' => independent, 'status' => status, 'agent' => native.fetch('agent'),
        'control_passed' => @live ? nil : control_passed?(task, native, independent, status),
        'category' => category(task) }
    end

    def native_status(native)
      return 'infrastructure_error' unless native.fetch('outcome').fetch('scored')
      return 'infrastructure_error' unless native['reward'].is_a?(Numeric) && native['reward'].finite?

      native['reward'] == 1 ? 'passed' : 'failed'
    end

    def category(task)
      return 'foundry' if task.metadata['group']
      return 'smoke' if task.name == 'hello-world'

      task.name.start_with?('ft-') ? 'feature' : 'atomic'
    end
  end
end
