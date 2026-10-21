# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/generation/skill_upgrade'
require_relative 'support/skill_upgrades'

class SkillUpgradeEdgesTest < FoundryTest
  include SkillUpgradeHelpers

  Upgrade = RailsAIFoundry::Generation::SkillUpgrade
  Error = RailsAIFoundry::InstallationError

  def setup
    super
    @target = 'agents'
    @path = '.agents/skills/foundry-verify/SKILL.md'
    @receipt = '.foundry/skills/agents.json'
    install
  end

  def test_new_and_retired_files_change_and_rollback_without_touching_unowned_files
    added = '.agents/skills/foundry-verify/references/verification.md'
    remove_owned(added)
    retired = add_retired('removed.md', customized: false)
    write('.agents/skills/foundry-verify/local.md', 'private local note')
    before = installed
    id = digest
    command.call(apply: id)
    assert_equal incoming(added), read(added)
    refute File.exist?(File.join(@root, retired))
    assert_equal 'private local note', read('.agents/skills/foundry-verify/local.md')
    command.call(rollback: id)
    assert_equal before, installed
  end

  def test_retired_kept_file_is_unmanaged_after_completion
    retired = add_retired('retired-local.md', customized: true)
    id = digest
    assert_raises(Error) { command.call(apply: id) }
    decisions(id, retired => 'keep_local')
    command.call(resolve: "#{directory(id)}/decisions.json")
    File.unlink(File.join(@root, retired))
    File.symlink('/private/tmp', File.join(@root, retired))
    install
    assert File.symlink?(File.join(@root, retired))
    assert_raises(Error) { command.call(rollback: id) }
  end

  def test_already_upstream_is_not_a_conflict
    content = read(@path)
    old(@path, 'old', local: content)
    assert_includes command.call, "current #{@path}"
    command.call(apply: digest)
    assert_equal content, read(@path)
  end

  def test_explicit_upstream_retirement_and_resolution_pretend
    retired = add_retired('removed.md', customized: true)
    id = digest
    assert_raises(Error) { command.call(apply: id) }
    decisions(id, retired => 'use_upstream')
    before = snapshot
    command.call(resolve: "#{directory(id)}/decisions.json", pretend: true)
    assert_equal before, snapshot
    command.call(resolve: "#{directory(id)}/decisions.json")
    refute File.exist?(File.join(@root, retired))
    before = snapshot
    command.call(rollback: id, pretend: true)
    assert_equal before, snapshot
    command.call(rollback: id)
    assert_equal 'custom retired', read(retired)
  end

  def test_invalid_decision_sets_and_actions_are_rejected_without_mutation
    old(@path, 'old', local: 'local')
    id = digest
    assert_raises(Error) { command.call(apply: id) }
    path = "#{directory(id)}/decisions.json"
    [[], { 'session' => 'a' * 64, 'files' => {} }, { 'session' => id, 'files' => {} }].each do |document|
      write(path, JSON.generate(document))
      before = snapshot
      assert_raises(Error) { command.call(resolve: path) }
      assert_equal before, snapshot
    end
    assert_raises(Error) { command.call(apply: id, rollback: id) }
    assert_raises(Error) { command.call(rollback: '../escape') }
  end

  def test_pending_artifacts_are_private_and_content_never_enters_output
    old(@path, 'old', local: 'sensitive-guidance-marker')
    id = digest
    refute_includes command.call.join, 'sensitive-guidance-marker'
    failure = assert_raises(Error) { command.call(apply: id) }
    refute_includes failure.message, 'sensitive-guidance-marker'
    assert_includes read('.foundry/skill-upgrades/.gitignore'), '*'
    assert_equal 0o700, File.stat(File.join(@root, directory(id))).mode & 0o777
    assert_equal 0o600, File.stat(File.join(@root, directory(id), 'plan.json')).mode & 0o777
    before = snapshot
    assert_raises(Error) { command.call }
    assert_equal before, snapshot
  end

  def test_no_writes_when_an_unrelated_reviewed_file_changes_before_resolution
    old(@path, 'old', local: 'local')
    id = digest
    assert_raises(Error) { command.call(apply: id) }
    decisions(id, @path => 'keep_local')
    customize('.agents/skills/foundry-plan/SKILL.md')
    before = snapshot
    assert_raises(Error) { command.call(resolve: "#{directory(id)}/decisions.json") }
    assert_equal before, snapshot
  end
end
