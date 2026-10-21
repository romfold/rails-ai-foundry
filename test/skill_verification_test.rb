# frozen_string_literal: true

require_relative 'test_helper'
require 'bundler'

class SkillVerificationTest < FoundryTest
  SCRIPT = File.expand_path('../skills/foundry-verify/scripts/verify.rb', __dir__)

  def setup
    super
    minitest = Gem.loaded_specs.fetch('minitest').version.to_s
    write('Gemfile', "source 'https://rubygems.org'\ngem 'minitest', #{minitest.inspect}\n")
    write('bin/rails', <<~RUBY)
      require 'minitest/autorun'
      module ActionDispatch
        class IntegrationTest < Minitest::Test; end
        class SystemTestCase < Minitest::Test; end
      end
      ARGV.shift
      files = ARGV.empty? ? Dir['test/*_test.rb'] : ARGV.dup
      ARGV.clear
      files.each { |file| require File.expand_path(file) }
    RUBY
    test_file('test/baseline_test.rb', 'BaselineTest', 'Minitest::Test')
    test_file('test/caller_test.rb', 'HttpTest', 'ActionDispatch::IntegrationTest')
    test_file('test/system/screen_test.rb', 'ScreenTest', 'ActionDispatch::SystemTestCase')
  end

  def test_runs_baseline_http_and_explicit_browser_separately
    output, error, status = verify('--realtime', '--browser', 'test/system/screen_test.rb')
    assert status.success?, "#{output}\n#{error}"
    %w[baseline caller browser].each { |phase| assert_includes output, "Verified #{phase}:" }
    assert_includes output, 'RAILS_ENV=test'
  end

  def test_nonstandard_paths_and_delegated_test_methods
    write('components/orders/acceptance_test.rb', <<~RUBY)
      require_relative '../../support/http_behavior'
      class OrdersTest < ActionDispatch::IntegrationTest
        include HttpBehavior
      end
    RUBY
    write('support/http_behavior.rb', "module HttpBehavior; def test_endpoint; assert true; end; end\n")
    output, error, status = run_script('--caller', 'components/orders/acceptance_test.rb')
    assert status.success?, "#{output}\n#{error}"
    assert_includes output, 'Verified caller: 1 tests'
  end

  def test_http_verification_does_not_load_optional_browser_dependencies
    path = 'bin/rails'
    content = File.read(File.join(@root, path))
    write(path, content.sub('class SystemTestCase < Minitest::Test; end', "autoload :SystemTestCase, 'absent_browser'"))
    output, error, status = verify
    assert status.success?, "#{output}\n#{error}"
  end

  def test_rejects_empty_selected_file_despite_passing_baseline
    write('test/caller_test.rb', '# no tests')
    assert_rejected('no tests executed')
  end

  def test_rejects_a_selected_file_that_only_loads_unrelated_tests
    write('test/caller_test.rb', "require_relative 'baseline_test'\n")
    assert_rejected('executed no ActionDispatch::IntegrationTest tests')
  end

  def test_rejects_unit_tests_as_http_evidence
    test_file('test/caller_test.rb', 'HttpTest', 'Minitest::Test')
    assert_rejected('executed no ActionDispatch::IntegrationTest tests')
  end

  def test_rejects_http_tests_as_browser_evidence
    test_file('test/system/screen_test.rb', 'ScreenTest', 'ActionDispatch::IntegrationTest')
    assert_rejected('executed no ActionDispatch::SystemTestCase tests', '--realtime',
                    '--browser', 'test/system/screen_test.rb')
  end

  def test_rejects_assertion_free_tests
    test_file('test/caller_test.rb', 'HttpTest', 'ActionDispatch::IntegrationTest', 'nil')
    assert_rejected('assertion-free tests')
  end

  def test_rejects_skipped_selected_test_even_when_baseline_skip_is_reviewed
    test_file('test/caller_test.rb', 'HttpTest', 'ActionDispatch::IntegrationTest', "skip 'not implemented'")
    assert_rejected('caller: failed, skipped', '--allow-baseline-skip', 'HttpTest#test_behavior')
  end

  def test_rejects_skipped_browser_requirement
    test_file('test/system/screen_test.rb', 'ScreenTest', 'ActionDispatch::SystemTestCase', "skip 'no browser'")
    assert_rejected('browser: failed, skipped', '--realtime', '--browser', 'test/system/screen_test.rb')
  end

  def test_preserves_reviewed_baseline_skips_explicitly
    test_file('test/baseline_test.rb', 'BaselineTest', 'Minitest::Test', "skip 'known environment limitation'")
    assert_rejected('baseline: failed, skipped')
    output, error, status = verify('--allow-baseline-skip', 'BaselineTest#test_behavior')
    assert status.success?, "#{output}\n#{error}"
    assert_includes output, 'Reviewed baseline skip: BaselineTest#test_behavior'
  end

  def test_rejects_failing_http_and_browser_commands
    test_file('test/caller_test.rb', 'HttpTest', 'ActionDispatch::IntegrationTest', 'assert false')
    assert_rejected('caller: command failed', '--baseline', 'test/baseline_test.rb')
    test_file('test/caller_test.rb', 'HttpTest', 'ActionDispatch::IntegrationTest')
    test_file('test/system/screen_test.rb', 'ScreenTest', 'ActionDispatch::SystemTestCase', 'assert false')
    assert_rejected('browser: command failed', '--realtime', '--browser', 'test/system/screen_test.rb')
  end

  def test_rejects_a_forged_stdout_summary_without_test_evidence
    write('bin/rails', "puts '999 tests, 999 assertions, 0 failures, 0 errors, 0 skips'\n")
    assert_rejected('test process produced no Minitest evidence')
  end

  def test_rejects_a_process_exiting_before_reporting
    write('bin/rails', 'exit! 0')
    assert_rejected('test process produced no Minitest evidence')
  end

  def test_preflights_all_selections_before_running_tests
    test_file('test/caller_test.rb', 'HttpTest', 'ActionDispatch::IntegrationTest', "raise 'should never execute'")
    output, error, status = verify('--realtime', '--browser', 'test/missing.rb')
    refute status.success?
    assert_includes error, 'missing.rb'
    refute_includes output, '[baseline]'
  end

  def test_requires_browser_selection_for_realtime
    assert_rejected('Realtime verification requires --browser', '--realtime')
  end

  def test_rejects_nonlocal_paths_and_unexpected_arguments
    Dir.mktmpdir do |external|
      path = File.join(external, 'test.rb')
      File.write(path, '# external')
      assert_rejected('application-local file', '--caller', path)
    end
    assert_rejected('Unexpected arguments', 'ignored.rb')
    assert_rejected('Timeout must be', '--timeout', '0')
  end

  def test_rejects_timeout_and_does_not_reuse_a_previous_pass
    output, error, status = verify
    assert status.success?, "#{output}\n#{error}"
    test_file('test/caller_test.rb', 'HttpTest', 'ActionDispatch::IntegrationTest', 'sleep 30')
    assert_rejected('Command exceeded 1 seconds', '--timeout', '1')
  end

  private

  def test_file(path, name, parent, body = "assert_equal 'test', ENV.fetch('RAILS_ENV')")
    write(path, "class #{name} < #{parent}; def test_behavior; #{body}; end; end\n")
  end

  def verify(*arguments)
    run_script('--caller', 'test/caller_test.rb', *arguments)
  end

  def run_script(*arguments)
    Bundler.with_unbundled_env do
      Open3.capture3({ 'RUBYOPT' => nil, 'MT_NO_PLUGINS' => '1' }, RbConfig.ruby,
                     SCRIPT, '--app', @root, *arguments)
    end
  end

  def assert_rejected(message, *arguments)
    output, error, status = verify(*arguments)
    refute status.success?, output
    assert_includes error, message, "#{output}\n#{error}"
    refute_includes output, 'Selected feature verification passed'
  end
end
