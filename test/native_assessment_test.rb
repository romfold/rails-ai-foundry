# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/cli'

class NativeAssessmentTest < FoundryTest
  def setup
    super
    write('Gemfile', "raise 'must not evaluate Gemfile'")
    write('config/application.rb', "raise 'must not boot Rails'")
    write('packs.yml', "pack_paths:\n- components/*\n")
    write('components/billing/package.yml', "enforce_dependencies: true\ndependencies: []\n")
    write('components/billing/foundry.yml', "namespace: Billing\nprofile: modular\n")
    write('components/billing/package_todo.yml', "# accepted debt must remain byte-for-byte intact\n")
  end

  def test_adoption_recommends_openspec_without_initialization_or_mutation
    before = snapshot
    report = run_assessment('adopt')
    assert_equal 'openspec', report['workflow']
    refute report['workflow_initialized']
    assert_equal 'balanced', report['workload']
    assert_includes report['packages'], 'components/billing'
    assert_empty report['accepted_debt']
    assert_equal(['components/billing'], report['contexts'].map { |context| context['path'] })
    assert_equal before, snapshot
  end

  def test_adoption_preserves_detected_or_configured_workflow_and_accepts_explicit_override
    write('.specify/memory/constitution.md', '# established workflow')
    assert_equal 'spec_kit', run_assessment('adopt')['workflow']
    write('config/foundry.yml', "workflow:\n  specs: none\n")
    before = snapshot
    assert_equal 'none', run_assessment('adopt')['workflow']
    assert_equal 'openspec', run_assessment('adopt', '--specs=openspec')['workflow']
    assert_equal before, snapshot
  end

  def test_ambiguous_workflows_fail_without_files_changed
    write('.specify/memory/constitution.md', '# workflow')
    write('openspec/config.yaml', 'schema: spec-driven')
    before = snapshot
    error = failed_assessment('adopt')
    assert_includes error, 'Both Spec Kit and OpenSpec'
    assert_equal 'none', run_assessment('adopt', '--specs=none')['workflow']
    assert_equal before, snapshot
  end

  def test_structural_check_does_not_claim_packwerk_or_behavioral_verification
    before = snapshot
    report = run_assessment('check')
    assert_equal 'structural', report['mode']
    assert_includes report['verification'], 'Packwerk boundaries were not checked'
    assert_equal before, snapshot
  end

  def test_duplicate_namespaces_and_invalid_intent_fail_structural_checks
    write('components/payments/package.yml', '{}')
    write('components/payments/foundry.yml', 'namespace: Billing')
    assert_includes failed_assessment('check'), 'multiple owners'
    write('components/payments/foundry.yml', "namespace: Payments\nprofile: event_sourced\n")
    assert_includes failed_assessment('check'), 'Unknown profile'
  end

  def test_unrelated_configuration_is_ignored_without_writes
    write('config/other_tool.yml', "enabled: true\n")
    before = snapshot
    assert_equal 'openspec', run_assessment('adopt')['workflow']
    assert_equal 'structural', run_assessment('check')['mode']
    assert_equal before, snapshot
  end

  def test_non_application_and_invalid_options_are_rejected
    assert_includes failed_assessment('adopt', '--boundaries'), 'only supported by foundry check'
    assert_includes failed_assessment('adopt', '--write'), 'invalid option'
    assert_includes failed_assessment('check', '--format=unknown'), 'invalid argument'
    File.unlink(File.join(@root, 'config/application.rb'))
    assert_includes failed_assessment('adopt'), 'consuming Rails application'
  end

  def test_explicit_boundary_check_propagates_failure_and_preserves_upstream_output
    require 'rails_ai_foundry/conventions/boundary_check'
    result = { 'success' => false, 'baselines_unchanged' => true, 'commands' => [] }
    checker = Object.new
    checker.define_singleton_method(:call) { result }
    stdout = StringIO.new
    RailsAIFoundry::Conventions::BoundaryCheck.stub(:new, ->(*) { checker }) do
      status = RailsAIFoundry::CLI.new.call(['check', "--root=#{@root}", '--boundaries', '--format=json'],
                                            stdout: stdout, stderr: StringIO.new)
      assert_equal 1, status
    end
    report = JSON.parse(stdout.string)
    refute report.dig('boundaries', 'success')
    assert_includes report['verification'], 'may have booted Rails'
  end

  private

  def run_assessment(action, *arguments)
    stdout = StringIO.new
    stderr = StringIO.new
    status = RailsAIFoundry::CLI.new.call([action, "--root=#{@root}", '--format=json', *arguments],
                                          stdout: stdout, stderr: stderr)
    assert_equal 0, status, stderr.string
    JSON.parse(stdout.string)
  end

  def failed_assessment(action, *arguments)
    stderr = StringIO.new
    status = RailsAIFoundry::CLI.new.call([action, "--root=#{@root}", *arguments],
                                          stdout: StringIO.new, stderr: stderr)
    assert_equal 1, status
    stderr.string
  end
end
