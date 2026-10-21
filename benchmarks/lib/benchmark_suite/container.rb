# frozen_string_literal: true

require 'securerandom'
require_relative 'support'

module BenchmarkSuite
  # Fresh verification only; trial execution remains owned by Le Mans.
  class Container
    attr_reader :name

    def initialize(image, workdir, tests:, process_limit: 256)
      @image = image
      @tests = tests
      @workdir = workdir
      @process_limit = process_limit
      @name = "foundry-verification-#{SecureRandom.hex(8)}"
    end

    def start
      Support.docker('run', '--detach', '--init', '--name', name, '--network', 'none',
                     '--read-only', '--cap-drop', 'ALL', '--security-opt', 'no-new-privileges',
                     '--pids-limit', @process_limit.to_s, '--memory', '2g', '--cpus', '2',
                     '--tmpfs', '/tmp:rw,nosuid,size=512m,mode=1777',
                     '--tmpfs', '/logs:rw,nosuid,size=64m', '--tmpfs', '/lemans:rw,nosuid,size=64m',
                     '--mount', "type=bind,source=#{@tests},target=/tests,readonly", '--volume', @workdir,
                     '--env', 'HOME=/tmp/home', '--env', 'BUNDLE_APP_CONFIG=/tmp/bundle',
                     '--env', 'RAILS_ENV=test', '--workdir', @workdir, '--entrypoint', 'sh',
                     @image, '-c', 'exec tail -f /dev/null')
      exec!('mkdir -p /tmp/home')
      self
    end

    def exec(command, timeout: 600, env: {})
      arguments = env.flat_map { |key, value| ['--env', "#{key}=#{value}"] }
      started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      result = Support.docker('exec', *arguments, name, 'timeout', timeout.to_i.to_s,
                              'sh', '-c', command, check: false, timeout: timeout + 30)
      Lemans::Environment::ExecResult.new(command: command, exit_code: result['exit_code'],
                                          output: result['output'],
                                          duration: Process.clock_gettime(Process::CLOCK_MONOTONIC) - started)
    end

    def exec!(command, **options)
      result = exec(command, **options)
      raise Failure, "Verification command failed: #{result.exit_code}" unless result.success?

      result
    end

    def upload(local, remote)
      exec!("mkdir -p #{Shellwords.escape(File.dirname(remote))}")
      Support.docker('exec', '-i', name, 'ruby', '-e', 'File.binwrite(ARGV.fetch(0), STDIN.read)', remote,
                     stdin_data: File.binread(local))
    end

    def download(remote, local)
      Pathname(local).dirname.mkpath
      Support.docker('cp', "#{name}:#{remote}", local.to_s)
    end

    def stop
      Support.docker('rm', '--force', '--volumes', name, check: false)
    end
  end
end
