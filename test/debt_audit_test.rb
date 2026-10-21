# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/conventions/debt_audit'

class DebtAuditTest < FoundryTest
  IDENTITY = ['.', 'packs/billing', '::Billing::Invoice', 'privacy', 'app/report.rb'].freeze

  def setup
    super
    write('Gemfile', '# locked consumer')
    write('Gemfile.lock', '# installed')
    write('config/application.rb', '# app')
    write('packwerk.yml', '{}')
    write('package_todo.yml', debt_yaml)
    write('app/report.rb', 'Billing::Invoice')
  end

  def test_resolved_and_new_identities_are_not_count_comparisons
    audit = RailsAIFoundry::Conventions::DebtAudit.new(@root, pks: RbConfig.ruby)
    replacement = [*IDENTITY[0...-1], 'app/new_report.rb']
    before = snapshot
    audit.stub(:regenerate, ->(*) { [[replacement], []] }) do
      report = audit.call
      assert_equal [IDENTITY], report['resolved']
      assert_equal [replacement], report['new']
      refute report['success']
      assert report['source_unchanged']
    end
    assert_equal before, snapshot
  end

  def test_fully_resolved_debt_is_reported_without_changing_source
    audit = RailsAIFoundry::Conventions::DebtAudit.new(@root, pks: RbConfig.ruby)
    audit.stub(:regenerate, ->(*) { [[], []] }) do
      result = audit.call
      assert result['success']
      assert_equal [IDENTITY], result['resolved']
    end
    assert_equal debt_yaml, File.read(File.join(@root, 'package_todo.yml'))
  end

  def test_regeneration_cannot_update_original_baselines
    audit = RailsAIFoundry::Conventions::DebtAudit.new(@root, pks: RbConfig.ruby)
    audit.stub(:execute, lambda { |_backend, action, directory|
      refute_equal File.realpath(@root), directory
      refute File.exist?(File.join(directory, 'package_todo.yml')) if action == 'validate'
      File.write(File.join(directory, 'package_todo.yml'), debt_yaml) if action == 'update-todo'
      { 'exit_status' => 0 }
    }) do
      assert audit.call['success']
    end
    assert_equal debt_yaml, File.read(File.join(@root, 'package_todo.yml'))
  end

  def test_snapshot_excludes_secrets_and_rejects_source_symlinks
    write('.env', 'secret')
    write('config/credentials.yml.enc', 'secret')
    copy = RailsAIFoundry::Conventions::AuditSnapshot.new(@root)
    copy.copy do |directory|
      refute File.exist?(File.join(directory, '.env'))
      refute File.exist?(File.join(directory, 'config/credentials.yml.enc'))
      assert File.exist?(File.join(directory, 'app/report.rb'))
    end
    File.symlink('/etc/hosts', File.join(@root, 'app/unsafe.rb'))
    assert_raises(RailsAIFoundry::ConfigurationError) { copy.fingerprint }
  end

  def test_parity_mismatch_and_stale_evidence_fail_closed
    audit = RailsAIFoundry::Conventions::DebtAudit.new(@root, pks: RbConfig.ruby)
    audit.stub(:regenerate, ->(backend, _captured) { [backend == :packwerk ? [IDENTITY] : [], []] }) do
      audit.stub(:execute, ->(*) { { 'stdout' => 'tool 1' } }) do
        report = audit.call(parity: true)
        refute report['success']
        assert_equal [IDENTITY], report['packwerk_only']
        assert_raises(RailsAIFoundry::ConfigurationError) { audit.verify(report) }
      end
    end
    audit.stub(:regenerate, ->(*) { [[IDENTITY], []] }) do
      audit.stub(:execute, ->(*) { { 'stdout' => 'tool 1' } }) do
        report = audit.call(parity: true)
        assert audit.verify(report)['success']
        report['tools']['pks'] = 'changed tool'
        assert_raises(RailsAIFoundry::ConfigurationError) { audit.verify(report) }
        write('app/report.rb', 'changed')
        assert_raises(RailsAIFoundry::ConfigurationError) { audit.verify(report) }
      end
    end
  end

  def test_malformed_debt_fails_before_analysis
    write('package_todo.yml', "packs/billing: []\n")
    assert_raises(RailsAIFoundry::ConfigurationError) { RailsAIFoundry::Conventions::Debt.identities(@root) }
  end

  def test_audit_and_parity_normalize_real_capture_results
    [false, true].each do |parity|
      audit = RailsAIFoundry::Conventions::DebtAudit.new(@root, pks: RbConfig.ruby)
      output = "\u{1f4e6} tool 1".dup.force_encoding(Encoding::US_ASCII)
      status = Struct.new(:exitstatus) { def success? = exitstatus.zero? }.new(0)
      Open3.stub(:capture3, ->(*) { [output, "bad \xff".b, status] }) do
        report = JSON.parse(JSON.generate(audit.call(parity: parity)))
        assert report['success']
        report.fetch('commands').each do |command|
          assert_equal "\u{1f4e6} tool 1", command['stdout']
          assert_equal "bad \uFFFD", command['stderr']
          assert_equal 0, command['exit_status']
        end
      end
    end
  end

  def test_failed_audit_command_preserves_normalized_diagnostics
    status = Struct.new(:exitstatus) { def success? = false }.new(9)
    Open3.stub(:capture3, ->(*) { ["\u{1f4e6}".b, "bad \xff".b, status] }) do
      error = assert_raises(RailsAIFoundry::ConfigurationError) do
        RailsAIFoundry::Conventions::DebtAudit.new(@root).call
      end
      assert_includes error.message, 'failed (9)'
      assert_includes error.message, "\u{1f4e6}"
      assert_includes error.message, "bad \uFFFD"
    end
  end

  private

  def debt_yaml
    "packs/billing:\n  '::Billing::Invoice':\n    violations: [privacy]\n    files: [app/report.rb]\n"
  end
end
