# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/workflows/selection'

class WorkflowSelectionTest < FoundryTest
  def selection
    RailsAIFoundry::Workflows::Selection.new(@root)
  end

  def test_defaults_are_based_on_invocation_not_parent_repository
    assert_equal 'spec_kit', selection.resolve(greenfield: true)
    assert_equal 'openspec', selection.resolve
    write('openspec/config.yaml', "schema: spec-driven\n")
    FileUtils.mkdir_p(File.join(@root, 'child'))
    child = RailsAIFoundry::Workflows::Selection.new(File.join(@root, 'child'))
    assert_equal 'spec_kit', child.resolve(greenfield: true)
    assert_empty child.detected
  end

  def test_explicit_then_configured_then_detected_precedence
    write('openspec/config.yaml', "schema: spec-driven\n")
    assert_equal 'openspec', selection.resolve(greenfield: true)
    write('config/foundry.yml', "workflow:\n  specs: none\n")
    assert_equal 'none', selection.resolve
    assert_equal 'spec_kit', selection.resolve(explicit: 'spec-kit')
  end

  def test_ambiguous_detection_requires_a_selection
    write('openspec/config.yaml', "schema: spec-driven\n")
    write('.specify/memory/constitution.md', '# Principles')
    assert_raises(RailsAIFoundry::ConfigurationError) { selection.resolve }
    assert_equal 'openspec', selection.resolve(explicit: 'openspec')
    write('config/foundry.yml', "workflow:\n  specs: spec_kit\n")
    assert_equal 'spec_kit', selection.resolve
  end

  def test_none_and_preview_content_preserve_existing_artifacts_and_settings
    write('config/foundry.yml', "workload: realtime\nworkflow:\n  specs: openspec\ndefaults:\n  profile: domain\n")
    write('openspec/config.yaml', "schema: spec-driven\n")
    before = snapshot
    data = YAML.safe_load(selection.content('none'))
    assert_equal 'none', data.dig('workflow', 'specs')
    assert_equal 'domain', data.dig('defaults', 'profile')
    assert_equal 'realtime', data['workload']
    assert_equal before, snapshot
    assert selection.initialized?('none')
  end

  def test_rejects_unsafe_or_invalid_configuration
    ["workflow: []\n", "workflow:\n  specs: unknown\n", "dependencies: []\n",
     "workflow: {}\nworkflow: {}\n", "workflow: &a {}\nother: *a\n", "--- !ruby/object:ERB {}\n",
     "workflow: <%= raise 'executed' %>\n"].each do |source|
      write('config/foundry.yml', source)
      assert_raises(RailsAIFoundry::ConfigurationError) { selection }
    end
  end

  def test_rejects_symlinks_and_stale_publication
    files = RailsAIFoundry::Conventions::Files.new(@root)
    write('outside.yml', "workflow: {}\n")
    FileUtils.mkdir_p(File.join(@root, 'config'))
    File.symlink('../outside.yml', File.join(@root, 'config/foundry.yml'))
    assert_raises(RailsAIFoundry::ConfigurationError) { selection }
    File.unlink(File.join(@root, 'config/foundry.yml'))
    write('config/foundry.yml', "workflow: {}\n")
    assert_raises(RailsAIFoundry::InstallationError) do
      files.publish('config/foundry.yml', 'replacement', expected: 'stale')
    end
    assert_equal "workflow: {}\n", files.read('config/foundry.yml')
    assert_raises(RailsAIFoundry::ConfigurationError) { files.read('../outside.yml') }
  end
end
