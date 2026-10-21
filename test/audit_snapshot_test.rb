# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/conventions/debt_audit'

class AuditSnapshotTest < FoundryTest
  def test_private_metadata_is_excluded_before_reading_and_receipts_remain
    write('.claude/skills/local/SKILL.md', 'private synthetic guidance')
    write('.foundry/skill-upgrades/agents/session/package_todo.yml', 'invalid: [')
    write('.foundry/skills/agents.json', '{}')
    write('packs/billing/.foundry/components.json', '{}')
    capture = RailsAIFoundry::Conventions::AuditSnapshot.new(@root)
    expected = %w[.foundry/skills/agents.json packs/billing/.foundry/components.json]
    assert_equal expected, capture.inventory.keys
    capture.copy do |directory|
      assert_equal expected, RailsAIFoundry::Conventions::AuditSnapshot.new(directory).inventory.keys
      refute File.exist?(File.join(directory, '.claude'))
      refute File.exist?(File.join(directory, '.foundry/skill-upgrades'))
      assert_equal 0o700, File.stat(directory).mode & 0o777
    end
  end

  def test_excluded_baselines_are_not_accepted_debt
    debt = "other:\n  Invoice:\n    violations: [privacy]\n    files: [app/a.rb]\n"
    write('vendor/example/package_todo.yml', debt)
    write('.claude/package_todo.yml', debt)
    write('.foundry/skill-upgrades/package_todo.yml', debt)
    write('components/billing/package_todo.yml',
          "other:\n  Invoice:\n    violations: [privacy]\n    files: [app/a.rb]\n")
    assert_equal [['components/billing', 'other', 'Invoice', 'privacy', 'app/a.rb']],
                 RailsAIFoundry::Conventions::Debt.identities(@root)
    write('vendor/example/package_todo.yml', "invalid: [\n")
    assert_equal 1, RailsAIFoundry::Conventions::Debt.identities(@root).size
  end

  def test_copied_bytes_are_checked_even_if_source_is_restored
    write('app/model.rb', 'original')
    capture = RailsAIFoundry::Conventions::AuditSnapshot.new(@root)
    destination = nil
    copy = FileUtils.method(:cp)
    FileUtils.stub(:cp, lambda { |source, target|
      destination = File.dirname(target, 2)
      File.write(source, 'transient')
      copy.call(source, target)
      File.write(source, 'original')
    }) do
      assert_raises(RailsAIFoundry::ConfigurationError) { capture.copy { flunk 'Inconsistent copy was yielded' } }
    end
    refute File.exist?(destination)
    assert_equal 'original', File.read(File.join(@root, 'app/model.rb'))
  end

  def test_policy_revision_and_private_edits_control_fingerprints
    write('app/model.rb', 'original')
    capture = RailsAIFoundry::Conventions::AuditSnapshot.new(@root)
    original = capture.fingerprint
    refute_equal Digest::SHA256.hexdigest(JSON.generate(capture.inventory)), original
    write('.claude/local.md', 'synthetic private edit')
    write('.foundry/skill-upgrades/session/local.md', 'synthetic private edit')
    assert_equal original, capture.fingerprint
    write('.foundry/skills/agents.json', '{}')
    refute_equal original, capture.fingerprint
  end

  def test_excluded_symlinks_are_not_followed_and_included_symlinks_fail
    File.symlink('/missing-synthetic-private-directory', File.join(@root, '.claude'))
    capture = RailsAIFoundry::Conventions::AuditSnapshot.new(@root)
    assert_empty capture.inventory
    File.symlink('/missing-synthetic-source', File.join(@root, 'source.rb'))
    assert_raises(RailsAIFoundry::ConfigurationError) { capture.inventory }
  end

  def test_debt_uses_one_read_and_reports_missing_or_unreadable_inputs_safely
    write('package_todo.yml', "{}\n")
    capture = RailsAIFoundry::Conventions::AuditSnapshot.new(@root)
    reads = 0
    capture.files.stub(:read, lambda { |_path|
      reads += 1
      raise 'Second read' if reads > 1

      "{}\n"
    }) do
      RailsAIFoundry::Conventions::AuditSnapshot.stub(:new, capture) do
        assert_empty RailsAIFoundry::Conventions::Debt.identities(@root)
      end
    end
    assert_equal 1, reads
    [->(*) {}, ->(*) { raise Errno::EACCES }].each do |fault|
      capture.files.stub(:read, fault) do
        RailsAIFoundry::Conventions::AuditSnapshot.stub(:new, capture) do
          error = assert_raises(RailsAIFoundry::ConfigurationError) do
            RailsAIFoundry::Conventions::Debt.identities(@root)
          end
          assert_includes error.message, 'package_todo.yml'
          refute_includes error.message, @root
        end
      end
    end
  end
end
