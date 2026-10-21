# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/conventions/context_installer'
require 'rails_ai_foundry/conventions/agent_installer'
require 'rails_ai_foundry/conventions/component_installer'

class NativeAgentGenerationTest < FoundryTest
  def setup
    super
    write('Gemfile', '# Consumer')
    write('config/application.rb', "raise 'must not boot'\n")
    RailsAIFoundry::Conventions::ContextInstaller.new(@root, 'support',
                                                      capabilities: { 'ai' => { 'adapter' => 'ruby_llm' } }).call
  end

  def test_preview_repeat_and_shared_configuration_preserve_application_choices
    before = snapshot
    assert(installer.call(pretend: true).any? { |action| action.include?('config/ai.yml') })
    assert_equal before, snapshot
    installer.call
    configuration = "shared:\n  models:\n    support:\n      model: selected-by-app\n      provider: openai\n"
    write('config/ai.yml', configuration)
    write('packs/support/app/prompts/support/summarize_agent/instructions.txt', 'Application-owned instructions')
    before = snapshot
    installer.call
    assert_equal before, snapshot
    installer('classify').call
    assert_equal configuration, File.read(File.join(@root, 'config/ai.yml'))
    assert_equal before['packs/support/foundry.yml'], snapshot['packs/support/foundry.yml']
    refute defined?(RubyLLM)
  end

  def test_collision_and_partial_scaffold_leave_all_other_files_unchanged
    prompt = 'packs/support/app/prompts/support/summarize_agent/instructions.txt'
    write(prompt, 'Unrelated prompt')
    before = snapshot
    assert_raises(RailsAIFoundry::InstallationError) { installer.call }
    assert_equal before, snapshot
    File.unlink(File.join(@root, prompt))
    installer.call
    File.unlink(File.join(@root, prompt))
    before = snapshot
    assert_raises(RailsAIFoundry::InstallationError) { installer.call }
    assert_equal before, snapshot
  end

  def test_missing_or_invalid_shared_configuration_is_not_silently_replaced
    write('config/ai.yml', 'models: [')
    before = snapshot
    assert_raises(RailsAIFoundry::ConfigurationError) { installer.call }
    assert_equal before, snapshot
    File.unlink(File.join(@root, 'config/ai.yml'))
    installer.call
    File.unlink(File.join(@root, 'config/ai.yml'))
    assert_raises(RailsAIFoundry::InstallationError) { installer.call }
    refute File.exist?(File.join(@root, 'config/ai.yml'))
  end

  def test_capability_selection_is_explicit_and_does_not_change_other_dimensions
    intent = YAML.safe_load_file(File.join(@root, 'packs/support/foundry.yml'))
    intent['capabilities'] = {}
    write('packs/support/foundry.yml', YAML.dump(intent))
    before = snapshot
    error = assert_raises(RailsAIFoundry::ConfigurationError) { installer.call }
    assert_includes error.message, 'capabilities.ai.adapter: ruby_llm'
    assert_equal before, snapshot
  end

  def test_all_profiles_keep_ai_delivery_and_nested_namespace_prompt_paths
    %w[rails_native modular domain].each do |profile|
      intent = RailsAIFoundry::Conventions::Intent.new('namespace' => 'Platform::Search', 'profile' => profile)
      files = RailsAIFoundry::Conventions::AgentTemplates.new(intent, 'summarize').files('components/search')
      assert files.key?('components/search/app/agents/platform/search/summarize_agent.rb')
      assert files.key?('components/search/app/prompts/platform/search/summarize_agent/instructions.txt')
      refute(files.values.any? { |content| content.include?('RailsAIFoundry::') })
    end
  end

  def test_prompt_symlink_is_rejected_without_touching_its_target
    FileUtils.mkdir_p(File.join(@root, 'packs/support/app'))
    FileUtils.mkdir_p(File.join(@root, 'external'))
    File.symlink(File.join(@root, 'external'), File.join(@root, 'packs/support/app/prompts'))
    before = snapshot
    assert_raises(RailsAIFoundry::InstallationError) { installer.call }
    assert_equal before, snapshot
    assert_empty Dir.children(File.join(@root, 'external'))
  end

  def test_component_claims_prevent_agent_generation_and_preview
    %w[agent tool schema].each do |suffix|
      name = "answer_#{suffix}"
      RailsAIFoundry::Conventions::ComponentInstaller.new(@root, "#{name}_#{suffix}",
                                                          context: 'support', kind: 'query').call
      before = snapshot
      [true, false].each do |pretend|
        error = assert_raises(RailsAIFoundry::InstallationError) { installer(name).call(pretend: pretend) }
        assert_includes error.message, '.foundry/components/query/'
        assert_equal before, snapshot
      end
    end
    refute File.exist?(File.join(@root, 'config/ai.yml'))
  end

  def test_complete_application_prompt_receipt_preserves_original_paths_and_edits
    installer.call
    receipt_path = 'packs/support/.foundry/agents/summarize.yml'
    receipt = YAML.safe_load_file(File.join(@root, receipt_path))
    receipt['paths'] = receipt.fetch('paths').filter_map do |path|
      if path.end_with?('/evaluation.yml')
        File.unlink(File.join(@root, path))
        next
      end
      destination = path.sub('packs/support/app/prompts/', 'app/prompts/')
      unless path == destination
        write(destination, File.read(File.join(@root, path)))
        File.unlink(File.join(@root, path))
      end
      destination
    end
    write(receipt_path, YAML.dump(receipt))
    write('app/prompts/support/summarize_agent/instructions.txt', 'Customized application prompt')
    before = snapshot
    installer.call
    installer.call(pretend: true)
    assert_equal before, snapshot
  end

  def test_receipts_cannot_claim_unrelated_files
    installer.call
    path = 'packs/support/.foundry/agents/summarize.yml'
    receipt = YAML.safe_load_file(File.join(@root, path))
    receipt['paths'] << 'config/ai.yml'
    write(path, YAML.dump(receipt))
    before = snapshot
    assert_raises(RailsAIFoundry::InstallationError) { installer.call }
    assert_equal before, snapshot
  end

  def test_existing_agent_receipt_prevents_all_three_component_claims
    installer('answer').call
    write('packs/support/app/agents/support/answer_agent.rb', '# customized')
    before = snapshot
    %w[agent tool schema].each do |suffix|
      component = RailsAIFoundry::Conventions::ComponentInstaller.new(@root, "answer_#{suffix}",
                                                                      context: 'support', kind: 'query')
      [true, false].each do |pretend|
        error = assert_raises(RailsAIFoundry::InstallationError) { component.call(pretend: pretend) }
        assert_includes error.message, '.foundry/agents/answer.yml'
        assert_equal before, snapshot
      end
    end
    installer('answer').call
    assert_equal before, snapshot
  end

  private

  def installer(name = 'summarize')
    RailsAIFoundry::Conventions::AgentInstaller.new(@root, name, context: 'support')
  end
end
