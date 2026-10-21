# frozen_string_literal: true

module BenchmarkSuite
  # Preserve upstream's baseline short-circuit while recording structured evidence.
  class VerificationPhases
    attr_reader :phase, :checks_dir, :baseline_exit_code

    def initialize(container, task, evidence)
      @container = container
      @task = task
      @evidence = evidence
      @checks_dir = task.verifier.logs_dir
    end

    def call
      @deadline = monotonic + @task.verifier.timeout
      if @task.verifier.preverify
        execution = baseline
        return execution unless execution.success?
      end
      @phase = 'task'
      @checks_dir = @task.verifier.logs_dir
      execute(@task.verifier.command, environment, 'verification.log')
    end

    private

    def baseline
      @phase = 'baseline'
      @checks_dir = File.join(@task.verifier.logs_dir, 'baseline')
      @container.exec!("mkdir -p #{Shellwords.escape(checks_dir)}")
      variables = environment.merge('FOUNDRY_BASELINE_CHECKS' => '1',
                                    'RUBYOPT' => '-I/tests -report-lemans -rfoundry_baseline')
      execution = execute(@task.verifier.preverify, variables, 'preverify.log')
      @baseline_exit_code = execution.exit_code
      validate_baseline(execution, capture_baseline_checks)
      execution
    end

    def validate_baseline(execution, data)
      return unless execution.success?
      return if data.fetch('checks').values.all? { |status| %w[pass skip].include?(status) }

      raise Failure, 'Baseline exit status disagrees with structured checks'
    end

    def capture_baseline_checks
      checks = @container.exec("cat #{Shellwords.escape(File.join(checks_dir, 'checks.json'))}")
      data = checks.success? ? JSON.parse(checks.output) : {}
      @evidence.json('preverify-checks.json', data)
      raise Failure, 'Application baseline did not produce structured checks' if data.fetch('checks', {}).empty?

      data
    end

    def execute(command, variables, log)
      remaining = (@deadline - monotonic).floor
      raise Failure, 'Verification time budget exhausted' unless remaining.positive?

      execution = @container.exec(command, timeout: remaining, env: variables)
      @evidence.write(log, execution.output)
      execution
    end

    def environment
      { 'TESTS' => '/tests', 'LOGS' => checks_dir,
        'WORKDIR' => @task.environment.workdir, 'RUBYOPT' => '-I/tests' }
    end

    def monotonic
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end
end
