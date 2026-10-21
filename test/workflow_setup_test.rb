# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/workflows/setup'
require 'rails_ai_foundry/cli'

class WorkflowSetupTest < FoundryTest
  def setup
    super
    write('Gemfile', "source 'https://rubygems.org'\n")
    write('config/application.rb', "raise 'must not boot'\n")
    @output = StringIO.new
  end

  def installer
    RailsAIFoundry::Workflows::Setup.new(@root, stdout: @output)
  end

  def test_new_application_can_use_parent_tool_binary_without_inheriting_parent_configuration
    tool
    write('config/foundry.yml', "workflow:\n  specs: none\n")
    write('openspec/config.yaml', 'schema: parent')
    write('child/Gemfile', '# child application')
    write('child/config/application.rb', "raise 'must not boot'")
    child = File.join(@root, 'child')
    setup = RailsAIFoundry::Workflows::Setup.new(child, stdout: StringIO.new, tool_root: @root)
    setup.call(specs: 'openspec', greenfield: true)
    assert_equal 'openspec', YAML.safe_load_file(File.join(child, 'config/foundry.yml')).dig('workflow', 'specs')
    assert_equal 'none', YAML.safe_load_file(File.join(@root, 'config/foundry.yml')).dig('workflow', 'specs')
    assert_equal 'schema: parent', File.read(File.join(@root, 'openspec/config.yaml'))
    assert_includes File.read(File.join(child, 'openspec/config.yaml')), 'schema: spec-driven'
  end

  def test_none_needs_no_tooling_and_preserves_existing_specs
    write('openspec/config.yaml', 'schema: spec-driven')
    write('config/foundry.yml', "workload: ingestion\ndefaults:\n  profile: modular\n")
    installer.call(specs: 'none')
    assert_equal 'schema: spec-driven', File.read(File.join(@root, 'openspec/config.yaml'))
    config = YAML.safe_load_file(File.join(@root, 'config/foundry.yml'))
    assert_equal 'ingestion', config['workload']
    assert_equal({ 'specs' => 'none' }, config['workflow'])
    assert_equal({ 'profile' => 'modular' }, config['defaults'])
    before = snapshot
    installer.call
    assert_equal before, snapshot
    assert_empty @output.string
  end

  def test_preview_runs_native_tool_only_in_staging_and_installs_nothing
    tool
    before = snapshot
    actions = installer.call(pretend: true)
    assert_includes actions, 'would create openspec/config.yaml'
    assert_equal before, snapshot
    assert_includes @output.string, '--profile core'
    assert_includes @output.string, '--tools codex'
  end

  def test_native_initialization_repeats_preserve_edited_artifacts_and_modes
    tool
    installer.call
    assert File.executable?(File.join(@root, 'openspec/script.sh'))
    refute File.exist?(File.join(@root, RailsAIFoundry::Workflows::Setup::JOURNAL))
    write('openspec/config.yaml', 'schema: customized')
    before = snapshot
    installer.call
    assert_equal before, snapshot
    assert_includes installer.doctor, 'workflow: openspec (initialized)'
  end

  def test_collisions_and_partial_installations_preserve_the_application
    tool
    write('.agents/skills/upstream/SKILL.md', 'user content')
    before = snapshot
    assert_raises(RailsAIFoundry::InstallationError) { installer.call }
    assert_equal before, snapshot
    write('openspec/existing.md', '# Existing')
    before = snapshot
    assert_raises(RailsAIFoundry::InstallationError) { installer.call }
    assert_equal before, snapshot
  end

  def test_failed_upstream_never_publishes_configuration
    tool(failure: true)
    before = snapshot
    error = assert_raises(RailsAIFoundry::InstallationError) { installer.call }
    assert_includes error.message, 'exited 7'
    assert_includes @output.string, 'upstream failed'
    assert_equal before, snapshot
  end

  def test_wrong_version_is_actionable_and_does_not_run_init
    tool(version: '9.9.9')
    before = snapshot
    error = assert_raises(RailsAIFoundry::ConfigurationError) { installer.call }
    assert_includes error.message, 'Expected openspec 1.12.0'
    assert_includes error.message, 'npm install'
    assert_equal before, snapshot
  end

  def test_version_banner_supports_non_ascii_output_in_ascii_locales
    tool(version: "\u2502 CLI Version 1.12.0 \u2502")
    installer.call
    assert_equal 'openspec', YAML.safe_load_file(File.join(@root, 'config/foundry.yml')).dig('workflow', 'specs')
  end

  def test_missing_tool_is_actionable_without_success_claim
    original = ENV.fetch('PATH')
    ENV['PATH'] = '/nonexistent'
    before = snapshot
    error = assert_raises(RailsAIFoundry::ConfigurationError) { installer.call(specs: 'spec-kit') }
    assert_includes error.message, 'Python >= 3.11'
    assert_includes error.message, 'v1.0.0'
    assert_equal before, snapshot
  ensure
    ENV['PATH'] = original
  end

  def test_interrupted_setup_requires_review_before_any_mutation
    write(RailsAIFoundry::Workflows::Setup::JOURNAL, 'files: [openspec/config.yaml]')
    before = snapshot
    error = assert_raises(RailsAIFoundry::InstallationError) { installer.call(specs: 'none') }
    assert_includes error.message, 'interrupted'
    assert_equal before, snapshot
  end

  def test_stale_selection_is_rejected_even_when_it_would_otherwise_be_a_no_op
    write('config/foundry.yml', "workflow:\n  specs: none\n")
    stale = installer
    write('config/foundry.yml', "workflow:\n  specs: openspec\n")
    before = snapshot
    assert_raises(RailsAIFoundry::InstallationError) { stale.call(specs: 'none') }
    assert_equal before, snapshot
  end

  def test_cli_and_application_validation
    stderr = StringIO.new
    arguments = ['setup', "--root=#{@root}", '--specs=none']
    assert_equal 0, RailsAIFoundry::CLI.new.call(arguments, stdout: @output, stderr: stderr)
    assert_empty stderr.string
    assert_includes @output.string, 'selected none'
    File.unlink(File.join(@root, 'config/application.rb'))
    assert_equal 1, RailsAIFoundry::CLI.new.call(arguments, stdout: @output, stderr: stderr)
    assert_includes stderr.string, 'consuming Rails application'
  end

  private

  def tool(version: '1.12.0', failure: false)
    write('node_modules/.bin/openspec', <<~RUBY)
      #!#{RbConfig.ruby}
      require 'fileutils'
      if ARGV == ['--version']
        puts #{version.inspect}
        exit
      end
      if #{failure}
        warn 'upstream failed'
        exit 7
      end
      FileUtils.mkdir_p('openspec')
      FileUtils.mkdir_p('.agents/skills/upstream')
      File.write('openspec/config.yaml', "schema: spec-driven\n")
      File.write('openspec/script.sh', '#!/bin/sh')
      File.chmod(0o755, 'openspec/script.sh')
      File.write('.agents/skills/upstream/SKILL.md', '# Upstream test fixture')
    RUBY
    File.chmod(0o755, File.join(@root, 'node_modules/.bin/openspec'))
  end
end
