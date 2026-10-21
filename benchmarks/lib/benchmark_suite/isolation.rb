# frozen_string_literal: true

require_relative 'container'
require_relative 'trusted_tests'

module BenchmarkSuite
  class Isolation
    def self.check(workspace, output)
      new(workspace, output).check
    end

    def initialize(workspace, output)
      @root = Pathname(workspace).realpath
      @output = Support.external_directory(output)
      @task = Lemans::Config.load_file(@root).tasks.first
      @image = JSON.parse(@root.join('images.json').read).fetch(@task.environment_image.name).fetch('id')
    end

    def check
      previous = ENV.fetch('BENCHMARK_ISOLATION_TOKEN', nil)
      ENV['BENCHMARK_ISOLATION_TOKEN'] = 'synthetic-isolation-credential'
      candidate = candidate_probe
      grader = grader_probe
      Support.json(@output.join('isolation.json'), { 'candidate' => candidate, 'grader' => grader, 'image' => @image })
    ensure
      ENV['BENCHMARK_ISOLATION_TOKEN'] = previous
    end

    private

    def candidate_probe
      environment = Lemans::Environments::Docker.new(image: Lemans::Config::ImageSpec.registry(@image),
                                                     resources: @task.environment.resources,
                                                     network: Lemans::Config::NetworkPolicy.new('none'))
      environment.start
      result = environment.exec!("ruby -e #{Shellwords.escape(candidate_script)}")
      { 'exit_code' => result.exit_code, 'output' => result.output }
    ensure
      environment&.stop
    end

    def candidate_script
      <<~RUBY_CODE
        paths = ['/tests', '/solution', '/var/run/docker.sock', #{REPOSITORY.to_s.inspect}, #{@root.to_s.inspect}, #{@output.to_s.inspect}]
        abort 'Candidate accessed forbidden material' if paths.any? { |path| File.exist?(path) }
        commits = IO.popen(['git', '-C', #{@task.environment.workdir.inspect}, 'rev-list', '--all', '--count'], &:read)
        abort 'Candidate inherited repository history' unless commits.strip == '1'
        abort 'Unexpected API credentials' if ENV.keys.any? { |key| key.end_with?('_API_KEY') }
        abort 'Host credential inherited' if ENV.key?('BENCHMARK_ISOLATION_TOKEN')
        puts 'Candidate isolation passed'
      RUBY_CODE
    end

    def grader_probe
      tests = TrustedTests.new(@task)
      container = Container.new(@image, @task.environment.workdir, tests: tests.directory).start
      script = <<~RUBY_CODE
        abort 'Isolated home missing' unless File.directory?(ENV.fetch('HOME'))
        abort 'Docker socket exposed' if File.exist?('/var/run/docker.sock')
        abort 'Host credential inherited' if ENV.key?('BENCHMARK_ISOLATION_TOKEN')
        abort 'Unexpected API credentials' if ENV.keys.any? { |key| key.end_with?('_API_KEY') }
        abort 'Effective capabilities' unless File.readlines('/proc/self/status').find { |line| line.start_with?('CapEff:') }.split.last.to_i(16).zero?
        begin
          File.write('/tests/tampered', 'bad')
          abort 'Evaluator writable'
        rescue Errno::EROFS, Errno::EACCES
        end
        begin
          Socket.tcp('1.1.1.1', 443, connect_timeout: 1) { abort 'External network available' }
        rescue SystemCallError, IOError
        end
        puts 'Grader isolation passed'
      RUBY_CODE
      result = container.exec!("ruby -rsocket -e #{Shellwords.escape(script)}")
      { 'exit_code' => result.exit_code, 'output' => result.output }
    ensure
      container&.stop
      tests&.close
    end
  end
end
