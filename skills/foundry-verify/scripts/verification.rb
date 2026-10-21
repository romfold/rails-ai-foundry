# frozen_string_literal: true

require 'json'
require 'optparse'
require 'pathname'
require 'rbconfig'
require 'shellwords'
require 'tmpdir'
require 'timeout'
require_relative 'loaded_files'
require_relative 'package_baseline'

module FoundrySkillVerification
  class Failure < StandardError; end

  class Selection
    attr_reader :root, :timeout, :skips, :phases, :framework, :include_pack_tests

    def initialize(arguments)
      @framework = 'minitest'
      @root = Dir.pwd
      @timeout = 600
      @skips = []
      @phases = { 'baseline' => [], 'caller' => [], 'browser' => [] }
      parse(arguments)
      @root = File.realpath(@root)
      validate
    end

    private

    def parse(arguments)
      OptionParser.new do |options|
        options.banner = 'ruby verify.rb --caller TEST [--realtime --browser TEST]'
        options.on('--app PATH') { |value| @root = value }
        options.on('--timeout SECONDS', Integer) { |value| @timeout = value }
        options.on('--allow-baseline-skip CLASS#TEST') { |value| @skips << value }
        options.on('--realtime') { @realtime = true }
        phase_options(options)
        options.on('--help') do
          puts options
          exit
        end
      end.parse!(arguments)
      raise Failure, 'Unexpected arguments; supply explicit test files.' unless arguments.empty?
    end

    def framework_option(options)
      options.on('--framework NAME', %w[minitest rspec]) { |value| @framework = value }
    end

    def phase_options(options)
      framework_option(options)
      options.on('--include-pack-tests') { @include_pack_tests = true }
      @phases.each_key do |phase|
        options.on("--#{phase} PATH") { |value| @phases.fetch(phase) << value }
      end
    end

    def validate
      raise Failure, 'Timeout must be between 1 and 3600 seconds per phase.' unless (1..3600).cover?(@timeout)
      raise Failure, 'Select at least one HTTP integration test with --caller.' if @phases['caller'].empty?
      raise Failure, 'Realtime verification requires --browser test files.' if @realtime && @phases['browser'].empty?

      %w[Gemfile bin/rails].each { |path| resolve(path) }
      resolve_phases
    end

    def resolve_phases
      @phases.each do |phase, paths|
        @phases[phase] = paths.uniq.map { |path| resolve(path, directory: phase == 'baseline') }
      end
    end

    def resolve(path, directory: false)
      target = File.realpath(File.expand_path(path, @root))
      valid = target.start_with?("#{@root}/") && (File.file?(target) || (directory && File.directory?(target)))
      raise Failure, "Expected an application-local #{directory ? 'path' : 'file'}: #{path}" unless valid

      Pathname(target).relative_path_from(Pathname(@root)).to_s
    end
  end

  class Evidence
    def initialize(path, phase, files, selection)
      @phase = phase
      @files = files
      @selection = selection
      raise Failure, "#{phase}: test process produced no Minitest evidence." unless File.file?(path)

      report = JSON.parse(File.read(path))
      LoadedFiles.verify(report, files) if phase == 'baseline' && selection.include_pack_tests
      @rows = report.fetch('tests')
    rescue JSON::ParserError, KeyError
      raise Failure, "#{phase}: invalid Minitest evidence."
    end

    def verify
      raise Failure, "#{@phase}: no tests executed." unless @rows.is_a?(Array) && !@rows.empty?

      verify_outcomes
      verify_selection unless @phase == 'baseline'
      puts "Verified #{@phase}: #{@rows.size} tests, #{@rows.sum { |row| row.fetch('assertions') }} assertions."
      show_skips
    end

    private

    def verify_outcomes
      rejected = @rows.reject { |row| acceptable?(row) }
      unless rejected.empty?
        ids = rejected.map { |row| row['id'] }.join(', ')
        raise Failure, "#{@phase}: failed, skipped or assertion-free tests: #{ids}"
      end
      return if @rows.any? { |row| row['status'] == 'pass' && row.fetch('assertions').positive? }

      raise Failure, "#{@phase}: no passing assertions executed."
    end

    def show_skips
      @rows.select { |row| row['status'] == 'skip' }.each { |row| puts "Reviewed baseline skip: #{row['id']}" }
    end

    def acceptable?(row)
      return @phase == 'baseline' && @selection.skips.include?(row['id']) if row['status'] == 'skip'

      row['status'] == 'pass' && (@phase == 'baseline' || row.fetch('assertions').positive?)
    end

    def verify_selection
      @files.each do |file|
        key = @selection.include_pack_tests ? 'owned_files' : 'files'
        matches = @rows.select { |row| Array(row[key]).include?(file) && row['kind'] == @phase }
        next if matches.any?

        expected = @phase == 'caller' ? 'ActionDispatch::IntegrationTest' : 'ActionDispatch::SystemTestCase'
        raise Failure, "#{@phase}: #{file} executed no #{expected} tests."
      end
    end
  end

  class Runner
    def initialize(arguments)
      @selection = Selection.new(arguments)
    end

    def call
      Dir.mktmpdir('foundry-verification-') do |directory|
        discover_packages(File.join(directory, 'discovery.json')) if @selection.include_pack_tests
        @selection.phases.each do |phase, files|
          next if phase == 'browser' && files.empty?

          verify_phase(phase, files, File.join(directory, "#{phase}.json"))
        end
      end
      puts 'Selected feature verification passed. Review test coverage against the requested behavior.'
    end

    private

    def discover_packages(output)
      baseline = PackageBaseline.new(@selection)
      environment = { 'RAILS_ENV' => 'test', 'BUNDLE_GEMFILE' => File.join(@selection.root, 'Gemfile') }
      status = execute(environment, baseline.command(output))
      raise Failure, 'Package discovery failed before test execution.' unless status.success?

      @selection.phases['baseline'] = baseline.files(output)
    end

    def verify_phase(phase, files, output)
      command = phase_command(files)
      puts "[#{phase}] RAILS_ENV=test #{command.shelljoin}"
      $stdout.flush
      environment = { 'RAILS_ENV' => 'test', 'BUNDLE_GEMFILE' => File.join(@selection.root, 'Gemfile'),
                      'FOUNDRY_TEST_EVIDENCE' => output,
                      'FOUNDRY_PACKAGE_BASELINE' => @selection.include_pack_tests && phase == 'baseline' ? '1' : nil }
      status = execute(environment, command)
      raise Failure, "#{phase}: command failed (#{status.exitstatus || status.termsig})." unless status.success?

      evidence_class.new(output, phase, files, @selection).verify
    end

    def evidence_class
      return Evidence unless @selection.framework == 'rspec'

      require_relative 'rspec_evidence'
      RSpecEvidence
    end

    def phase_command(files)
      if @selection.framework == 'rspec'
        [RbConfig.ruby, '-rbundler/setup', File.join(__dir__, 'rspec_runner.rb'), *files.map { |path| "./#{path}" }]
      else
        [RbConfig.ruby, '-rbundler/setup', '-r', File.join(__dir__, 'minitest_reporter.rb'),
         'bin/rails', 'test', *files.map { |path| "./#{path}" }]
      end
    end

    def execute(environment, command)
      pid = Process.spawn(environment, *command, chdir: @selection.root, pgroup: true)
      Timeout.timeout(@selection.timeout) { Process.wait2(pid).last }
    rescue Timeout::Error
      raise Failure, "Command exceeded #{@selection.timeout} seconds; no successful evidence accepted."
    ensure
      terminate(pid) if pid
    end

    def terminate(pid)
      Process.kill('KILL', -pid)
    rescue Errno::ESRCH
      nil
    ensure
      begin
        Process.wait(pid)
      rescue Errno::ECHILD
        nil
      end
    end
  end
end
