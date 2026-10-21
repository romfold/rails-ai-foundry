# frozen_string_literal: true

require_relative 'test_helper'
require 'bundler'

class PackageVerificationTest < FoundryTest
  SCRIPT = File.expand_path('../skills/foundry-verify/scripts/verify.rb', __dir__)

  def setup
    super
    gems = %w[minitest packs-specification].map { |name| "gem '#{name}', '#{Gem.loaded_specs.fetch(name).version}'" }
    write('Gemfile', "source 'https://rubygems.org'\n#{gems.join("\n")}\n")
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
    write('packs/billing/package.yml', '{}')
    example('test/root_test.rb', 'RootTest')
    example('packs/billing/test/http_test.rb', 'HttpTest', parent: 'ActionDispatch::IntegrationTest')
  end

  def test_combines_root_plain_pack_and_explicit_tests
    example('acceptance/custom.rb', 'AdditionalTest')
    output = accepted('--baseline', 'acceptance/custom.rb')
    assert_includes output, 'Verified baseline: 3 tests'
    assert_includes output, 'Baseline root: test/root_test.rb'
    assert_includes output, 'Baseline package packs/billing:'
    assert_includes output, 'Baseline explicit: acceptance/custom.rb'
    example('test/root_test.rb', 'RootTest', body: 'assert false')
    rejected('baseline: command failed')
    example('test/root_test.rb', 'RootTest')
    example('packs/billing/test/http_test.rb', 'HttpTest', body: 'assert false',
                                                           parent: 'ActionDispatch::IntegrationTest')
    rejected('baseline: command failed')
  end

  def test_custom_nested_overlapping_and_root_packages
    write('package.yml', '{}')
    write('packs.yml', "pack_paths: ['.', 'packs/*', 'packs/**/*', 'components/*']\n")
    write('components/empty/package.yml', '{}')
    write('packs/billing/child/package.yml', '{}')
    example('packs/billing/child/test/child_test.rb', 'ChildTest')
    output = accepted('--baseline', 'packs/billing/test/http_test.rb')
    assert_includes output, 'Verified baseline: 3 tests'
    assert_includes output, 'Baseline package packs/billing/child:'
    assert_includes output, 'Package without baseline tests: components/empty'
  end

  def test_package_only_application_and_inherited_tests
    FileUtils.rm_rf(File.join(@root, 'test'))
    write('support/behavior.rb', 'module Behavior; def test_inherited; assert true; end; end')
    write('packs/billing/test/http_test.rb', <<~RUBY)
      require_relative '../../../support/behavior'
      class HttpTest < ActionDispatch::IntegrationTest; include Behavior; end
    RUBY
    assert_includes accepted, 'Verified baseline: 1 tests'
  end

  def test_browser_and_support_directories_are_not_automatic_baseline
    %w[fixtures dummy support].each { |name| write("packs/billing/test/#{name}/bad_test.rb", "raise 'excluded'") }
    browser = 'packs/billing/test/system/screen_test.rb'
    example(browser, 'ScreenTest', parent: 'ActionDispatch::SystemTestCase')
    output = accepted('--realtime', '--browser', browser)
    assert_includes output, "Deferred browser (select --browser): #{browser}"
    assert_includes output, 'Verified baseline: 2 tests'
    assert_includes output, 'Verified browser: 1 tests'
    rejected('require --browser', '--baseline', browser)
    rejected('require --browser', '--baseline', 'packs/billing/test/system')
  end

  def test_missing_package_or_root_file_cannot_hide_behind_passing_tests
    original = File.read(File.join(@root, 'bin/rails'))
    %w[test/root_test.rb packs/billing/test/http_test.rb].each do |omitted|
      write('bin/rails',
            original.sub('files.each', "files.reject! { |file| file.end_with?('#{omitted}') }; files.each"))
      rejected("planned files were not loaded: #{omitted}")
    end
  end

  def test_invalid_configurations_and_missing_dependency_preflight
    ["pack_paths: '../*'", "pack_paths: ['/outside/*']", '[]', 'invalid: ['].each do |config|
      write('packs.yml', config)
      output = rejected('Package discovery failed')
      refute_includes output, '[baseline]'
    end
    FileUtils.rm(File.join(@root, 'packs.yml'))
    write('Gemfile', "source 'https://rubygems.org'\ngem 'minitest'\n")
    rejected('requires packs-specification')
  end

  def test_unsafe_symlinks_and_ambiguous_package_aliases
    Dir.mktmpdir do |outside|
      File.write(File.join(outside, 'escape_test.rb'), "raise 'outside'")
      File.symlink(File.join(outside, 'escape_test.rb'), File.join(@root, 'test/escape_test.rb'))
      rejected('escapes the application')
      FileUtils.rm(File.join(@root, 'test/escape_test.rb'))
    end
    File.symlink(File.join(@root, 'packs/billing'), File.join(@root, 'packs/alias'))
    rejected('Ambiguous or unsafe package path')
  end

  def test_custom_environment_and_empty_baseline
    output, error, status = verify(env: { 'DEFAULT_TEST' => 'test/root_test.rb' })
    refute status.success?, output
    assert_includes error, 'Custom test discovery/filter environment'
    FileUtils.rm_rf(File.join(@root, 'test'))
    FileUtils.mv(File.join(@root, 'packs/billing/test/http_test.rb'), File.join(@root, 'caller.rb'))
    output, error, status = verify(caller: 'caller.rb')
    refute status.success?, output
    assert_includes error, 'found no non-system baseline tests'
    assert_includes output, 'Package without baseline tests: packs/billing'
  end

  def test_loaded_shared_file_does_not_need_to_own_a_test
    write('packs/billing/test/shared_test.rb', 'module SharedDefinition; end')
    assert_includes accepted, 'Verified baseline: 2 tests'
  end

  def test_shared_definition_cannot_claim_including_class_execution
    write('packs/billing/test/shared_test.rb', <<~RUBY)
      module SharedBehavior; def test_shared; assert true; end; end
      require_relative 'http_test'
    RUBY
    write('packs/billing/test/http_test.rb', <<~RUBY)
      require_relative 'shared_test'
      class HttpTest < ActionDispatch::IntegrationTest; include SharedBehavior; end
    RUBY
    output, error, status = verify(caller: 'packs/billing/test/shared_test.rb')
    refute status.success?, output
    assert_includes error, 'executed no ActionDispatch::IntegrationTest tests'
  end

  def test_package_mode_rejects_missing_reports_timeouts_and_interruption
    original = File.read(File.join(@root, 'packs/billing/test/http_test.rb'))
    ["puts '999 runs, 0 failures'; $stdout.flush; exit! 0", 'sleep 30',
     "Process.kill('INT', Process.pid); sleep 1"].each do |body|
      write('packs/billing/test/http_test.rb', body)
      output, error, status = verify('--timeout', '1')
      refute status.success?, "#{output}\n#{error}"
      refute_includes output, 'Selected feature verification passed'
    end
    write('packs/billing/test/http_test.rb', original)
  end

  private

  def example(path, name, parent: 'Minitest::Test', body: 'assert true')
    write(path, "class #{name} < #{parent}; def test_behavior; #{body}; end; end\n")
  end

  def verify(*arguments, env: {}, caller: 'packs/billing/test/http_test.rb')
    Bundler.with_unbundled_env do
      Open3.capture3({ 'RUBYOPT' => nil, 'MT_NO_PLUGINS' => '1' }.merge(env), RbConfig.ruby, SCRIPT,
                     '--app', @root, '--include-pack-tests', '--caller', caller, *arguments)
    end
  end

  def accepted(*arguments)
    output, error, status = verify(*arguments)
    assert status.success?, "#{output}\n#{error}"
    output
  end

  def rejected(message, *arguments)
    output, error, status = verify(*arguments)
    refute status.success?, output
    assert_includes error, message, "#{output}\n#{error}"
    output
  end
end
