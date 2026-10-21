# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'contract_report_helpers'
require 'rails_ai_foundry/cli'
require 'rails_ai_foundry/contracts'
require 'rails_ai_foundry/conventions/debt_audit'
require 'rails_ai_foundry/conventions/boundary_check'
require 'rails_ai_foundry/conventions/context_installer'
require 'rails_ai_foundry/conventions/component_installer'
require 'rails_ai_foundry/conventions/agent_installer'
require 'rails_ai_foundry/workflows/setup'

class StableContractsTest < FoundryTest
  include ContractReportHelpers

  def test_configuration_schema_cases_match_boot_free_ruby_validation
    cases = JSON.parse(File.read(File.join(__dir__, 'fixtures/contracts/configuration.json')))
    cases.each_with_index do |sample, index|
      write('config/foundry.yml', YAML.dump(sample['data']))
      before = snapshot
      validate = lambda {
        if sample['schema'] == 'application'
          RailsAIFoundry::Conventions::ApplicationConfig.new(@root)
        else
          RailsAIFoundry::Conventions::Intent.new(sample['data'])
        end
      }
      if sample['valid']
        validate.call
      else
        assert_raises(RailsAIFoundry::ConfigurationError, sample.inspect, &validate)
      end
      assert_equal before, snapshot
      sample!("configuration-#{index}", sample)
    end
  end

  def test_all_example_configuration_uses_the_published_contract
    root = File.expand_path('..', __dir__)
    Dir.glob('examples/**/foundry.yml', base: root).sort.each_with_index do |path, index|
      data = YAML.safe_load_file(File.join(root, path))
      application = path.end_with?('/config/foundry.yml')
      if application
        RailsAIFoundry::Conventions::ApplicationConfig.new(File.join(root, path.delete_suffix('/config/foundry.yml')))
      else
        RailsAIFoundry::Conventions::Intent.new(data)
      end
      sample!("example-#{index}",
              { 'schema' => application ? 'application' : 'context', 'valid' => true, 'data' => data })
    end
  end

  def test_discovery_is_boot_free_and_has_installed_assets
    before = snapshot
    stdout = StringIO.new
    assert_equal 0, RailsAIFoundry::CLI.new.call(['--version'], stdout: stdout)
    assert_equal "#{RailsAIFoundry::VERSION}\n", stdout.string
    report = cli('contracts')
    assert_equal 16, report.fetch('generators').size
    assert_equal 8, report.fetch('skills').size
    assert_equal 8, report.fetch('schemas').size
    report.fetch('schemas').each_value { |path| assert File.file?(path), path }
    assert_equal before, snapshot
    report!('contracts', report)
  end

  def test_schema_omitted_native_consumer_and_edited_component_survive_upgrade
    consumer
    write('config/foundry.yml', "workflow:\n  specs: none\ndefaults:\n  profile: modular\n")
    RailsAIFoundry::Conventions::ContextInstaller.new(@root, 'billing').call
    installer = RailsAIFoundry::Conventions::ComponentInstaller.new(@root, 'quote', context: 'billing', kind: 'query')
    installer.call
    path = 'packs/billing/app/queries/billing/quote.rb'
    write(path, '# application-owned behavior')
    before = snapshot
    installer.call
    RailsAIFoundry::Workflows::Setup.new(@root).call(specs: 'none')
    assert_equal before, snapshot
    report!('assessment', cli('check', '--format=json'))
    report!('assessment', cli('adopt', '--format=json'))
    report!('refactor', cli('plan', 'refactor', '--context=billing', '--format=json'))
  end

  def test_invalid_configuration_refuses_setup_without_modifying_application
    consumer
    RailsAIFoundry::Conventions::ContextInstaller.new(@root, 'billing').call
    write('config/foundry.yml', "schema: 2\n")
    before = snapshot
    error = StringIO.new
    assert_equal 1, RailsAIFoundry::CLI.new.call(['setup', "--root=#{@root}", '--specs=none'], stderr: error)
    assert_includes error.string, 'schema must be integer 1'
    assert_raises(RailsAIFoundry::ConfigurationError) do
      RailsAIFoundry::Conventions::ComponentInstaller.new(@root, 'quote', context: 'billing', kind: 'query').call
    end
    assert_raises(RailsAIFoundry::ConfigurationError) do
      RailsAIFoundry::Conventions::AgentInstaller.new(@root, 'quote', context: 'billing').call
    end
    assert_equal before, snapshot
  end

  def test_failed_source_report_preserves_diagnostic_contract
    consumer
    write('app/old.rb', 'class Old < RailsAIFoundry::Command; end')
    before = snapshot
    report = cli('check', '--sources', '--format=json', status: 1)
    refute report['success']
    item = report.fetch('sources').fetch('diagnostics').fetch(0)
    assert_equal 'source.foundry_dependency', item['rule']
    assert_equal 'detected', item['certainty']
    assert_equal 1, item['line']
    assert_equal before, snapshot
    report!('assessment', report)
    sample!('diagnostic', { 'schema' => 'diagnostic', 'valid' => true, 'data' => item })
  end

  def test_prompt_reports_preserve_the_optional_assessment_contract
    consumer
    RailsAIFoundry::Conventions::ContextInstaller.new(@root, 'support',
                                                      capabilities: { 'ai' => { 'adapter' => 'ruby_llm' } }).call
    RailsAIFoundry::Conventions::AgentInstaller.new(@root, 'answer', context: 'support').call
    report!('assessment', cli('check', '--prompts', '--format=json'))
    File.unlink(File.join(@root, 'packs/support/app/prompts/support/answer_agent/instructions.txt'))
    report = cli('check', '--prompts', '--sources', '--format=json', status: 1)
    refute report['success']
    assert report.dig('sources', 'success')
    refute report.dig('prompts', 'success')
    report!('assessment', report)
    sample!('prompt-diagnostic', { 'schema' => 'diagnostic', 'valid' => true,
                                   'data' => report.dig('prompts', 'diagnostics').first })
  end

  def test_advisory_source_reports_succeed_until_an_error_is_added
    consumer
    write('app/models/invoice.rb', 'class Invoice < ApplicationRecord; end')
    write('app/services/notify.rb', 'ApplicationRecord.transaction { RubyLLM.chat.ask("notice") }')
    refute cli('check', '--format=json').key?('sources')
    report = cli('check', '--sources', '--format=json')
    assert report['success']
    item = report.dig('sources', 'diagnostics').fetch(0)
    assert_equal 'warning', item['severity']
    assert_equal 'inferred', item['certainty']
    report!('assessment', report)
    sample!('advisory-diagnostic', { 'schema' => 'diagnostic', 'valid' => true, 'data' => item })
    write('app/queries/invoices.rb', 'Invoice.delete_all')
    before = snapshot
    report = cli('check', '--sources', '--format=json', status: 1)
    refute report['success']
    assert_equal %w[error warning], report.dig('sources', 'diagnostics').map { |finding| finding['severity'] }.sort
    assert_equal before, snapshot
    report!('assessment', report)
  end

  def test_boundary_failure_and_incomplete_refactor_reports
    consumer
    RailsAIFoundry::Conventions::ContextInstaller.new(@root, 'billing').call
    write('Gemfile.lock', '# installed fixture')
    write('packs/billing/app/invalid.rb', 'class Broken <')
    report!('refactor', cli('plan', 'refactor', '--context=billing', '--format=json', status: 1))
    checker = RailsAIFoundry::Conventions::BoundaryCheck.new(@root)
    command = { 'argv' => %w[packwerk validate], 'stdout' => 'upstream failure', 'stderr' => '', 'exit_status' => 1 }
    before = snapshot
    checker.stub(:execute, command) do
      RailsAIFoundry::Conventions::BoundaryCheck.stub(:new, ->(*) { checker }) do
        report = cli('check', '--boundaries', '--format=json', status: 1)
        refute report['success']
        assert report.dig('boundaries', 'baselines_unchanged')
        report!('assessment', report)
      end
    end
    assert_equal before, snapshot
  end

  def test_audit_reports_and_unsupported_parity_evidence
    consumer
    write('Gemfile.lock', '# installed fixture')
    write('packwerk.yml', '{}')
    audit = RailsAIFoundry::Conventions::DebtAudit.new(@root, pks: RbConfig.ruby)
    audit.stub(:regenerate, ->(*) { [[], []] }) do
      audit.stub(:execute, ->(*) { { 'stdout' => 'fixture tool 1' } }) do
        report!('debt', audit.call)
        report = audit.call(parity: true)
        report!('debt', report)
        assert audit.verify(report)['success']
        [nil, 2, '1', true].each do |version|
          assert_raises(RailsAIFoundry::ConfigurationError) { audit.verify(report.merge('report_schema' => version)) }
        end
        [nil, '0.5.0'].each do |version|
          assert_raises(RailsAIFoundry::ConfigurationError) { audit.verify(report.merge('foundry_version' => version)) }
        end
      end
    end
  end
end
