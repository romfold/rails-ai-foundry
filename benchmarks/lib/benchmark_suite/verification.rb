# frozen_string_literal: true

require_relative 'container'
require_relative 'evidence'
require_relative 'trusted_tests'
require_relative 'setup'
require_relative 'prerequisites'
require_relative 'protocol'
require_relative 'verification_phases'

module BenchmarkSuite
  class Verification
    def initialize(root, task_name, patch, output)
      @root = Pathname(root).realpath
      @task = Lemans::Config.load_file(@root).tasks.find { |task| task.name == task_name }
      raise Failure, 'Unknown task' unless @task

      @patch = Pathname(patch)
      @evidence = Evidence.new(output)
      @source_hashes = verification_sources
      @evidence.json('inputs.json', { 'task_digest' => @task.digest, 'verification_sources' => @source_hashes,
                                      'protocol' => Protocol.rules(@task), 'process_limit' => process_limit })
    end

    def call
      raise Failure, 'Captured patch missing' unless @patch.file?
      raise Failure, 'Multistep replay requires step checkpoints' if @task.multistep?

      result = execute
      raise Failure, 'Verification source changed during replay' unless @source_hashes == verification_sources

      @evidence.json('result.json', result)
      result
    rescue StandardError => e
      result = { 'status' => 'infrastructure_error', 'error_class' => e.class.name, 'message' => e.message }
      @evidence.json('result.json', result)
      result
    ensure
      @container&.stop
      @tests&.close
    end

    private

    def verification_sources
      names = %w[verification.rb container.rb support.rb evidence.rb trusted_tests.rb setup.rb prerequisites.rb
                 protocol.rb verification_phases.rb ../../verification/foundry_baseline.rb
                 ../../verification/minitest/foundry_baseline_plugin.rb]
      names.to_h do |name|
        [name, Digest::SHA256.file(ROOT.join('lib/benchmark_suite', name)).hexdigest]
      end
    end

    def execute
      start_container
      setup
      snapshot = Lemans::Trial::Snapshot.new(@task, @container)
      snapshot.capture!
      apply_patch
      violations = protected_changes
      result = verify(snapshot)
      result['verification_status'] = result.fetch('status')
      result['protocol_violations'] = violations
      result['status'] = 'invalid_protocol' unless violations.empty?
      result
    end

    def start_container
      @tests = TrustedTests.new(@task)
      @container = Container.new(resolved_image, @task.environment.workdir, tests: @tests.directory,
                                                                            process_limit: process_limit).start
    end

    def process_limit
      @task.metadata['group'] ? 256 : 1024
    end

    def resolved_image
      records = JSON.parse(@root.join('images.json').read)
      records.fetch(@task.environment_image.name).fetch('id')
    end

    def setup
      Setup.apply(@container, @task.setup, seed: @task.seed?,
                                           prepared_commands: Prerequisites.commands(@task, @root))
      @container.exec!('git add -A && git -c user.name=Verification -c user.email=verification@example.invalid ' \
                       'commit --allow-empty -qm "Sealed verification baseline"')
    end

    def apply_patch
      artifact = @evidence.write('agent.patch', @patch.binread)
      raise Failure, 'Non-replayable patch: credential filtering changed its bytes' if artifact['sanitized']

      @container.upload(@patch, '/tmp/candidate.patch')
      flag = @patch.empty? ? '--allow-empty ' : ''
      @container.exec!("git apply --binary #{flag}/tmp/candidate.patch")
      @container.exec!('git add -N .')
    end

    def protected_changes
      paths = Protocol.rules(@task).fetch('forbidden')
      return [] if paths.empty?

      output = @container.exec!("git diff --name-only -z HEAD -- #{Shellwords.join(paths)}").output
      output.split("\0").reject(&:empty?)
    end

    def verify(snapshot)
      execution = run_tests(snapshot)
      data = read_checks
      status = verification_status(execution, data)
      { 'task' => @task.name, 'status' => status, 'reward' => status == 'passed' ? 1.0 : 0.0,
        'patch_sha256' => Digest::SHA256.file(@patch).hexdigest, 'foundry' => foundry_checks,
        'verification_phase' => @phases.phase, 'baseline_exit_code' => @phases.baseline_exit_code }
    end

    def run_tests(snapshot)
      Setup.apply(@container, @task.verifier.setup)
      snapshot.restore!
      @container.exec!("mkdir -p #{Shellwords.escape(@task.verifier.logs_dir)}")
      @phases = VerificationPhases.new(@container, @task, @evidence)
      @phases.call
    end

    def read_checks
      checks = @container.exec("cat #{Shellwords.escape(File.join(@phases.checks_dir, 'checks.json'))}")
      data = checks.success? ? JSON.parse(checks.output) : {}
      @evidence.json('checks.json', data)
      data
    end

    def foundry_checks
      return unless @task.metadata['group']

      path = File.join(@task.verifier.logs_dir, 'foundry.json')
      result = @container.exec("cat #{Shellwords.escape(path)}")
      return unless result.success?

      data = JSON.parse(result.output)
      @evidence.json('foundry.json', data)
      data
    end

    def verification_status(execution, data)
      return 'infrastructure_error' unless [0, 1].include?(execution.exit_code)
      return 'infrastructure_error' if data.fetch('checks', {}).empty?
      return 'failed' unless execution.success?

      required_checks_pass?(data) ? 'passed' : 'failed'
    end

    def required_checks_pass?(data)
      allowed = data.fetch('allowed_failures', {}).keys
      data.fetch('checks').all? do |name, status|
        status == 'pass' || (status == 'fail (allowed)' && allowed.include?(name))
      end
    end
  end
end
