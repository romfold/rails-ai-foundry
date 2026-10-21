# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/conventions/boundary_check'

class NativeBoundaryCheckTest < FoundryTest
  def setup
    super
    write('Gemfile', '# consumer bundle')
    write('Gemfile.lock', '# locked')
    write('config/application.rb', '# Rails application')
    write('packwerk.yml', '{}')
    write('components/billing/package_todo.yml', "# reviewed\n{}\n")
  end

  def test_runs_only_upstream_validation_and_check_in_the_consuming_test_bundle
    commands = []
    before = snapshot
    Open3.stub(:capture3, lambda { |environment, *argv, **options|
      assert_equal File.join(File.realpath(@root), 'Gemfile'), environment['BUNDLE_GEMFILE']
      assert_equal 'true', environment['BUNDLE_FROZEN']
      assert_equal Bundler::VERSION, environment['BUNDLE_VERSION']
      assert_equal 'test', environment['RAILS_ENV']
      assert_equal 'test', environment['RACK_ENV']
      assert_equal File.realpath(@root), options[:chdir]
      commands << argv
      ['upstream output', '', Struct.new(:exitstatus).new(0)]
    }) do
      result = RailsAIFoundry::Conventions::BoundaryCheck.new(@root).call
      assert result['success']
      assert result['baselines_unchanged']
    end
    assert_equal %w[validate check], commands.map(&:last)
    assert(commands.all? do |argv|
      argv[1...-1] == ['-S', 'bundle', 'exec', RbConfig.ruby, '-rstringio', '-S', 'packwerk']
    end)
    assert_equal before, snapshot
  end

  def test_failed_validation_stops_before_boundary_check
    checker = RailsAIFoundry::Conventions::BoundaryCheck.new(@root)
    checker.stub(:execute, lambda { |action|
      assert_equal 'validate', action
      { 'exit_status' => 1 }
    }) do
      result = checker.call
      refute result['success']
      assert result['baselines_unchanged']
      assert_equal 1, result['commands'].size
    end
  end

  def test_unicode_and_invalid_bytes_are_reportable_without_changing_status_or_locale
    before = snapshot
    locale = ENV.to_h.slice('LANG', 'LC_ALL')
    [0, 1].each do |code|
      output = "\u{1f4e6} validation\n".dup.force_encoding(Encoding::US_ASCII)
      error = "bad \xff".b
      Open3.stub(:capture3, ->(*) { [output, error, Struct.new(:exitstatus).new(code)] }) do
        report = RailsAIFoundry::Conventions::BoundaryCheck.new(@root).call
        parsed = JSON.parse(JSON.generate(report))
        command = parsed.fetch('commands').first
        assert_equal "\u{1f4e6} validation\n", command['stdout']
        assert_equal "bad \uFFFD", command['stderr']
        assert_equal code.zero?, parsed['success']
        assert_equal code, command['exit_status']
      end
      assert_equal Encoding::US_ASCII, output.encoding
    end
    assert_equal locale, ENV.to_h.slice('LANG', 'LC_ALL')
    assert_equal before, snapshot
  end

  def test_baseline_changes_fail_even_when_upstream_exits_successfully
    checker = RailsAIFoundry::Conventions::BoundaryCheck.new(@root)
    checker.stub(:execute, lambda { |_action|
      write('components/billing/package_todo.yml', '# concurrent edit')
      { 'exit_status' => 0 }
    }) do
      result = checker.call
      refute result['success']
      refute result['baselines_unchanged']
    end
    assert_equal '# concurrent edit', File.read(File.join(@root, 'components/billing/package_todo.yml'))
  end

  def test_missing_prerequisites_and_unsafe_baselines_fail_before_execution
    checker = RailsAIFoundry::Conventions::BoundaryCheck.new(@root)
    checker.stub(:execute, ->(*) { flunk 'must not execute' }) do
      File.unlink(File.join(@root, 'Gemfile.lock'))
      assert_raises(RailsAIFoundry::ConfigurationError) { checker.call }
      write('Gemfile.lock', '# locked')
      File.symlink(File.join(@root, 'Gemfile'), File.join(@root, 'package_todo.yml'))
      assert_raises(RailsAIFoundry::ConfigurationError) { checker.call }
    end
  end
end
