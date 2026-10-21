# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/cli'
require 'rails_ai_foundry/conventions/new_application'

class NewApplicationTest < FoundryTest
  def test_preview_defaults_to_postgresql_and_does_not_inherit_parent_workflow
    write('openspec/config.yaml', 'schema: spec-driven')
    before = snapshot
    stdout = StringIO.new
    installer = RailsAIFoundry::Conventions::NewApplication.new(@root, stdout: stdout)
    upstream = RailsAIFoundry::Workflows::Upstream
    upstream.stub(:new, lambda { |*args, **|
      assert_equal 'spec_kit', args[1]
      Object.new.tap do |tool|
        def tool.check!; end
      end
    }) do
      messages = installer.call('shop', pretend: true)
      assert_includes messages.first, 'spec_kit'
    end
    assert_includes stdout.string, 'postgresql'
    assert_includes stdout.string, '--no-rc'
    assert_equal before, snapshot
    refute Dir.exist?(File.join(@root, 'shop'))
  end

  def test_rejects_existing_destinations_unsafe_names_and_missing_tools_before_creation
    write('shop/user.txt', 'preserve')
    before = snapshot
    installer = RailsAIFoundry::Conventions::NewApplication.new(@root, stdout: StringIO.new)
    assert_raises(RailsAIFoundry::InstallationError) { installer.call('shop', specs: 'none') }
    assert_raises(RailsAIFoundry::ConfigurationError) { installer.call('../other', specs: 'none') }
    assert_raises(RailsAIFoundry::ConfigurationError) { installer.call('other', specs: 'unknown') }
    assert_raises(RailsAIFoundry::ConfigurationError) { installer.call('other', specs: 'none', agent: 'unknown') }
    tool = Minitest::Mock.new
    tool.expect(:check!, nil) { raise RailsAIFoundry::ConfigurationError, 'missing tool' }
    RailsAIFoundry::Workflows::Upstream.stub(:new, tool) do
      assert_raises(RailsAIFoundry::ConfigurationError) { installer.call('other') }
    end
    assert_equal before, snapshot
    refute Dir.exist?(File.join(@root, 'other'))
  end

  def test_failed_rails_creation_preserves_artifacts_and_interruption_marker
    installer = RailsAIFoundry::Conventions::NewApplication.new(@root, stdout: StringIO.new)
    installer.stub(:execute, lambda { |_command|
      write('shop/Gemfile', '# incomplete application')
      raise RailsAIFoundry::InstallationError, 'Rails failed'
    }) do
      error = assert_raises(RailsAIFoundry::InstallationError) { installer.call('shop', specs: 'none') }
      assert_includes error.message, 'Creation incomplete'
    end
    assert File.exist?(File.join(@root, 'shop/.foundry/new-in-progress'))
    assert_equal '# incomplete application', File.read(File.join(@root, 'shop/Gemfile'))
    refute File.exist?(File.join(@root, 'shop/config/foundry.yml'))
  end

  def test_zero_rails_exit_without_completed_integrations_is_not_success
    installer = RailsAIFoundry::Conventions::NewApplication.new(@root, stdout: StringIO.new)
    installer.stub(:execute, nil) do
      error = assert_raises(RailsAIFoundry::InstallationError) { installer.call('shop', specs: 'none') }
      assert_includes error.message, 'Rails integration is incomplete'
    end
  end

  def test_cli_rejects_missing_name_and_unforwarded_rails_options
    [['new'], %w[new shop --force], %w[new shop --skip-bundle]].each do |arguments|
      assert_equal 1, RailsAIFoundry::CLI.new.call(arguments, stdout: StringIO.new, stderr: StringIO.new)
    end
  end
end
