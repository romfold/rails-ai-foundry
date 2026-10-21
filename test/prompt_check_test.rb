# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/cli'
require 'rails_ai_foundry/conventions/context_installer'
require 'rails_ai_foundry/conventions/agent_installer'

class PromptCheckTest < FoundryTest
  def setup
    super
    write('Gemfile', "raise 'must not execute'")
    write('config/application.rb', "raise 'must not boot'")
    write('config/foundry.yml', "workflow:\n  specs: none\n")
    write('packs.yml', "pack_paths:\n- components/*\n")
    RailsAIFoundry::Conventions::ContextInstaller.new(@root, 'support', path: 'components/support',
                                                                        namespace: 'Platform::API',
                                                                        capabilities: {
                                                                          'ai' => { 'adapter' => 'ruby_llm' }
                                                                        }).call
    RailsAIFoundry::Conventions::AgentInstaller.new(@root, 'answer', context: 'support').call
    @prompt = 'components/support/app/prompts/platform/api/answer_agent'
  end

  def test_generated_contract_checks_without_loading_or_evaluating_any_content
    write("#{@prompt}/instructions.txt", '<%= raise "do not evaluate" %>')
    write("#{@prompt}/evaluation.yml", 'This is application-owned evaluation input, not executable code.')
    before = snapshot
    status, report = check
    assert_equal 0, status
    assert_equal 1, report.dig('prompts', 'files_checked')
    assert_empty report.dig('prompts', 'diagnostics')
    assert_equal before, snapshot
    refute defined?(RubyLLM)
    refute defined?(Platform)
  end

  def test_missing_contract_and_artifact_fail_with_machine_readable_diagnostics
    File.unlink(File.join(@root, @prompt, 'evaluation.yml'))
    status, report = check
    assert_equal 1, status
    item = report.dig('prompts', 'diagnostics').first
    assert_equal 'prompt.contract', item['rule']
    assert_equal 'error', item['severity']
    assert_includes item['message'], 'evaluation.yml'
    File.unlink(File.join(@root, @prompt, 'contract.yml'))
    assert_equal 1, check.first
  end

  def test_invalid_shapes_and_ownership_are_rejected
    original = contract
    [{ 'schema' => 1.0 }, { 'inputs' => [] }, { 'tools' => ['eval(1)'] }, { 'owner' => '.' },
     { 'agent' => 'Another::Agent' }, { 'evaluations' => [] }, { 'unexpected' => true }].each do |values|
      write("#{@prompt}/contract.yml", YAML.dump(original.merge(values)))
      before = snapshot
      assert_equal 1, check.first, values.inspect
      assert_equal before, snapshot
    end
  end

  def test_escaping_and_symlink_references_are_rejected
    original = contract
    ['../instructions.txt', '/etc/passwd'].each do |reference|
      write("#{@prompt}/contract.yml", YAML.dump(original.merge('templates' => [reference])))
      assert_equal 1, check.first
    end
    write("#{@prompt}/contract.yml", YAML.dump(original))
    File.unlink(File.join(@root, @prompt, 'instructions.txt'))
    File.symlink('/etc/passwd', File.join(@root, @prompt, 'instructions.txt'))
    status, report, error = check
    assert_equal 1, status
    assert_nil report
    assert_includes error, 'Symbolic links'
    assert_includes error, @prompt
  end

  def test_scope_is_explicit_and_prompt_success_does_not_mask_source_failure
    write("#{@prompt}/contract.yml", 'invalid')
    assert_equal 0, check(prompts: false).first
    write("#{@prompt}/contract.yml", YAML.dump(valid_contract))
    write('app/models/runtime.rb', 'RailsAIFoundry::Runtime')
    status, report = check(sources: true)
    assert_equal 1, status
    assert report.dig('prompts', 'success')
    refute report.dig('sources', 'success')
  end

  private

  def contract
    @contract ||= YAML.safe_load_file(File.join(@root, @prompt, 'contract.yml'))
  end

  def valid_contract
    RailsAIFoundry::Conventions::AgentTemplates.new(
      RailsAIFoundry::Conventions::Intent.new('namespace' => 'Platform::API'), 'answer'
    ).files('components/support').then { |files| YAML.safe_load(files.fetch("#{@prompt}/contract.yml")) }
  end

  def check(prompts: true, sources: false)
    output = StringIO.new
    error = StringIO.new
    arguments = ['check', "--root=#{@root}", '--format=json']
    arguments << '--prompts' if prompts
    arguments << '--sources' if sources
    status = RailsAIFoundry::CLI.new.call(arguments, stdout: output, stderr: error)
    [status, output.string.empty? ? nil : JSON.parse(output.string), error.string]
  end
end
