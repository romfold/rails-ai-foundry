# frozen_string_literal: true

require_relative 'study_budget'
require_relative 'study_results'
require_relative 'openrouter_account'
require_relative 'evidence'

module BenchmarkSuite
  class StudyPreflight
    def self.call(root, task, output)
      new(root, task, output).call
    end

    def initialize(root, task, output, account: OpenrouterAccount.new)
      @root = Pathname(root).realpath
      @task = task
      @evidence = Evidence.new(output)
      @account = account
    end

    def call
      @root.join('preflights').mkpath
      File.open(@root.join('preflights/.lock'), File::RDWR | File::CREAT, 0o600) do |file|
        raise Failure, 'Another preflight is active' unless file.flock(File::LOCK_EX | File::LOCK_NB)

        issue_receipt
      end
    rescue StandardError => e
      @evidence.json('failure.json', { 'eligible' => false, 'error_class' => e.class.name,
                                       'reason' => e.is_a?(Failure) ? e.message : 'Preflight metadata invalid' })
      raise Failure, 'Study preflight refused; see sanitized failure.json'
    end

    private

    def issue_receipt
      result = validate
      Support.json(receipt_path, result)
      @evidence.json('preflight.json', result)
      result
    end

    def validate
      validate_inputs
      previous = predecessors
      snapshot = @account.snapshot
      accounting = StudyBudget.validate!(snapshot, previous: previous, first: first_receipt, attempt: @attempt)
      { 'eligible' => true, 'attempt' => @attempt, 'snapshot' => snapshot, 'accounting' => accounting,
        'manifest_sha256' => Digest::SHA256.file(@root.join('study.json')).hexdigest,
        'recorded_at' => Time.now.utc.iso8601 }
    end

    def validate_inputs
      manifest = Study.load(@root)
      Study.validate!(@root, manifest)
      @attempt = manifest.fetch('attempts').find { |row| row['task'] == @task }
      raise Failure, 'Task outside study' unless @attempt
      raise Failure, 'Attempt already reserved' if receipt_path.exist?
    end

    def predecessors
      rows = StudyResults.new(@root).records
      index = rows.index { |row| row['task'] == @task }
      validate_unstarted(rows.drop(index))
      previous = rows.take(index)
      validate_previous(previous)
      raise Failure, 'Smoke did not pass both graders' if previous.any? && previous.first['status'] != 'passed'

      previous
    end

    def validate_unstarted(rows)
      valid = rows.all? do |row|
        row['status'] == 'unstarted' && !@root.join('results', row['id']).exist?
      end
      raise Failure, 'Current or later attempt already started' unless valid
    end

    def validate_previous(rows)
      valid = rows.all? do |row|
        completed_assessment?(row) && @root.join('preflights', "#{row['id']}.json").file?
      end
      raise Failure, 'Previous attempt lacks a completed eligible independent assessment' unless valid
    end

    def completed_assessment?(row)
      return true if %w[passed failed incomplete].include?(row['status'])
      return false unless row['status'] == 'invalid_protocol' && row.dig('native', 'outcome', 'name') == 'completed'

      independent = row.dig('verification', 'independent')
      return false unless independent.is_a?(Hash)

      diagnosed_violation?(independent) && independent['reward'] == row.dig('native', 'reward')
    end

    def diagnosed_violation?(independent)
      independent['status'] == 'invalid_protocol' && independent['verification_phase'] == 'task' &&
        %w[passed failed].include?(independent['verification_status']) && valid_violations?(independent)
    end

    def valid_violations?(independent)
      violations = independent['protocol_violations']
      return false unless [0.0, 1.0].include?(independent['reward']) && violations.is_a?(Array)

      violations.any? && violations.all? { |path| path.is_a?(String) && !path.empty? }
    end

    def first_receipt
      path = @root.join('preflights', "#{Study.attempts.first['id']}.json")
      path.file? ? JSON.parse(path.read) : nil
    end

    def receipt_path
      @root.join('preflights', "#{@attempt.fetch('id')}.json")
    end
  end
end
