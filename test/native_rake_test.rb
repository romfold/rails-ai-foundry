# frozen_string_literal: true

require_relative 'test_helper'

class NativeRakeTest < FoundryTest
  def setup
    super
    FileUtils.cp_r(Dir[File.expand_path('dummy/*', __dir__)], @root)
    write('Gemfile', "source 'https://rubygems.org'\n")
    write('config/foundry.yml', "workflow:\n  specs: none\n")
  end

  def rails(*arguments)
    env = { 'BUNDLE_GEMFILE' => ENV.fetch('BUNDLE_GEMFILE', File.expand_path('../Gemfile', __dir__)) }
    Open3.capture3(env, RbConfig.ruby, 'bin/rails', *arguments, chdir: @root)
  end

  def test_native_checks_do_not_boot_or_execute_package_code
    write('packs/billing/package.yml', "{}\n")
    write('packs/billing/app/models/billing.rb', "raise 'Package code must not execute'\n")
    before = snapshot
    %w[foundry:check foundry:architecture:check foundry:architecture:conventions].each do |task|
      output, error, status = rails(task)
      assert status.success?, "#{output}\n#{error}"
      assert_includes output, 'Configuration only; Rails was not booted and Packwerk boundaries were not checked.'
    end
    assert_equal before, snapshot
  end

  def test_unconfigured_applications_use_native_checks_without_booting
    File.unlink(File.join(@root, 'config/foundry.yml'))
    output, error, status = rails('foundry:check')
    assert status.success?, "#{output}\n#{error}"
    assert_includes output, 'Rails was not booted'
    refute File.exist?(File.join(@root, 'config/other_tool.yml'))
  end

  def test_native_check_rejects_invalid_configuration_without_writes
    write('config/foundry.yml', "defaults:\n  profile: unsupported\n")
    before = snapshot
    _output, error, status = rails('foundry:check')
    refute status.success?
    assert_includes error, 'rails_native'
    assert_equal before, snapshot
  end

  def test_native_selection_ignores_unrelated_configuration
    write('config/other_tool.yml', "{}\n")
    output, error, status = rails('foundry:check')
    assert status.success?, "#{output}\n#{error}"
  end

  def test_boundaries_require_upstream_prerequisites
    _output, error, status = rails('foundry:architecture:boundaries')
    refute status.success?
    assert_includes error, 'installed, locked application bundle'
  end

  def test_explicit_source_check_reports_foundry_dependencies_without_booting
    write('packs/plain/package.yml', "{}\n")
    write('packs/plain/app/jobs/tool_reference.rb', "raise 'must not execute'\nRailsAIFoundry::UnitOfWork.new\n")
    before = snapshot
    output, error, status = rails('foundry:architecture:sources')
    refute status.success?, "#{output}\n#{error}"
    assert_includes output, 'packs/plain/app/jobs/tool_reference.rb:2 [error/detected:source.foundry_dependency]'
    assert_includes output, 'development-only Foundry'
    assert_equal before, snapshot
  end
end
