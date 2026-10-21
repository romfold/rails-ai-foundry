# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/conventions/refactor_command'
require 'rails_ai_foundry/cli'
require 'rails_ai_foundry/conventions/source_check'

class ContextRefactorTest < FoundryTest
  def setup
    super
    write('packs/billing/package.yml', 'enforce_dependencies: true')
    write('packs/billing/foundry.yml', "namespace: Billing\nprofile: modular\n")
  end

  def test_assessment_reports_source_evidence_without_executing_code_or_changing_configuration
    write('packs/billing/app/commands/billing/charge.rb', <<~RUBY)
      # RailsAIFoundry::Runtime is a comment, not a reference.
      class Billing::Charge < RailsAIFoundry::Command
        raise 'Do not execute during assessment'
      end
    RUBY
    before = snapshot
    result = RailsAIFoundry::Conventions::Refactor.new(@root).call(context: 'billing', profile: 'domain')
    assert_equal 'domain', result['proposed_profile']
    assert_equal 'modular', result['profile']
    assert_equal 1, result['findings'].size
    assert_equal 2, result['findings'].first['line']
    assert_equal 'RailsAIFoundry::Command', result['findings'].first['constant']
    assert_equal 'detected', result['findings'].first['certainty']
    assert_equal before, snapshot
  end

  def test_cli_json_and_invalid_profile
    output = StringIO.new
    error = StringIO.new
    args = ['plan', 'refactor', "--root=#{@root}", '--context=Billing', '--format=json']
    assert_equal 0, RailsAIFoundry::CLI.new.call(args, stdout: output, stderr: error)
    assert_equal 'packs/billing', JSON.parse(output.string)['context']
    assert_empty error.string
    args = ['plan', 'refactor', "--root=#{@root}", '--context=Billing', '--profile=event_sourced']
    assert_equal 1, RailsAIFoundry::CLI.new.call(args, stdout: output, stderr: error)
    assert_includes error.string, 'Unknown profile'
  end

  def test_shared_ast_diagnostics_ignore_other_owners_and_report_full_nested_names
    write('packs/billing/app/example.rb', <<~RUBY)
      Other::RailsAIFoundry::Operation
      'RailsAIFoundry::Runtime'
      ::RailsAIFoundry::AI::Agent.new
    RUBY
    result = RailsAIFoundry::Conventions::Refactor.new(@root).call(context: 'billing')
    assert result.fetch('complete')
    assert_equal(['RailsAIFoundry::AI::Agent'], result.fetch('findings').map { |item| item.fetch('constant') })
    assert_includes result.fetch('limitations'), 'Constant resolution is not proven'
  end

  def test_invalid_ruby_makes_refactor_incomplete_and_fails_the_cli_without_writes
    write('packs/billing/test/broken_test.rb', 'class Broken <')
    before = snapshot
    output = StringIO.new
    args = ['plan', 'refactor', "--root=#{@root}", '--context=billing', '--format=json']
    status = RailsAIFoundry::CLI.new.call(args, stdout: output, stderr: StringIO.new)
    assert_equal 1, status
    result = JSON.parse(output.string)
    refute result.fetch('complete')
    assert_equal 'source.syntax', result.fetch('findings').first.fetch('rule')
    assert_equal before, snapshot
  end

  def test_architecture_findings_match_source_check_and_keep_selected_context_scope
    write('packs/billing/app/models/billing/record.rb', 'class Billing::Record < ActiveRecord::Base; end')
    write('packs/billing/app/queries/billing/totals.rb', 'Billing::Record.update_all(amount: 1)')
    write('packs/billing/app/jobs/billing/provider_job.rb', 'RubyLLM.chat.ask("hello")')
    write('packs/other/package.yml', 'enforce_dependencies: true')
    write('packs/other/foundry.yml', "namespace: Other\nprofile: domain\n")
    write('packs/other/app/domain/broken.rb', 'class Broken <')
    before = snapshot
    result = RailsAIFoundry::Conventions::Refactor.new(@root).call(context: 'billing')
    contexts = [{ 'path' => 'packs/billing', 'profile' => 'modular', 'namespace' => 'Billing' }]
    source = RailsAIFoundry::Conventions::SourceCheck.new(@root, contexts: contexts, packages: ['packs/billing']).call
    assert result.fetch('complete')
    assert_equal(source.fetch('diagnostics'), result.fetch('findings').map { |item| item.except('path', 'advice') })
    assert_equal %w[source.delivery_provider source.query_write], result.fetch('findings').map { |item|
      item['rule']
    }.sort
    assert_equal before, snapshot
  end

  def test_proposed_domain_profile_does_not_pretend_installed_profile_changed
    write('packs/billing/app/domain/rule.rb', 'Rails.logger.info("message")')
    result = RailsAIFoundry::Conventions::Refactor.new(@root).call(context: 'billing', profile: 'domain')
    assert_empty result.fetch('findings')
    write('packs/billing/foundry.yml', "namespace: Billing\nprofile: domain\n")
    result = RailsAIFoundry::Conventions::Refactor.new(@root).call(context: 'billing')
    assert_equal 'source.domain_dependency', result.fetch('findings').first.fetch('rule')
    assert result.fetch('complete')
  end
end
