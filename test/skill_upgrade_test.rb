# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/generation/skill_upgrade'
require_relative 'support/skill_upgrades'

class SkillUpgradeTest < FoundryTest
  include SkillUpgradeHelpers

  Upgrade = RailsAIFoundry::Generation::SkillUpgrade
  Error = RailsAIFoundry::InstallationError

  def setup
    super
    @target = 'agents'
    install
    @path = '.agents/skills/foundry-verify/SKILL.md'
    @receipt = '.foundry/skills/agents.json'
  end

  def test_assessment_is_read_only_and_identifies_all_classifications
    old(@path, 'previous')
    customize('.agents/skills/foundry-plan/SKILL.md')
    old('.agents/skills/foundry-add-feature/SKILL.md', 'old', local: 'custom')
    old('.agents/skills/foundry-add-package/SKILL.md', 'old', local: incoming(@path))
    add_retired('untouched.txt', customized: false)
    add_retired('custom.txt', customized: true)
    remove_owned('.agents/skills/foundry-verify/references/verification.md')
    before = snapshot
    report = command.call
    %w[update customized review remove add unchanged].each do |action|
      assert report.any? { |line| line.start_with?("#{action} ") }, action
    end
    assert_equal before, snapshot
  end

  def test_all_targets_safe_upgrade_and_rollback_preserve_modes
    %w[agents claude cursor].each do |target|
      @target = target
      install unless target == 'agents'
      @path = ".#{target}/skills/foundry-verify/scripts/verify.rb"
      @receipt = ".foundry/skills/#{target}.json"
      old(@path, '# old executable')
      File.chmod(0o751, File.join(@root, @path))
      before = installed
      id = digest
      assert command.call(apply: id).first.include?('complete')
      assert_equal incoming(@path), read(@path)
      assert_equal 0o751, File.stat(File.join(@root, @path)).mode & 0o777
      assert command.call(rollback: id).first.include?('rolled back')
      assert_equal before, installed
    end
  end

  def test_rollback_allows_a_fresh_review_without_reusing_history
    old(@path, 'old')
    id = digest
    command.call(apply: id)
    command.call(rollback: id)
    next_id = digest
    refute_equal id, next_id
    command.call(apply: next_id)
    assert_equal 'rolled_back', state(id)['phase']
    assert_equal 'complete', state(next_id)['phase']
  end

  def test_stale_digest_and_pretend_never_write
    old(@path, 'old')
    id = digest
    before = snapshot
    command.call(apply: id, pretend: true)
    assert_equal before, snapshot
    customize(@path)
    before = snapshot
    assert_match(/Stale review/, assert_raises(Error) { command.call(apply: id) }.message)
    assert_equal before, snapshot
  end

  def test_review_preserves_receipt_until_explicit_decisions_and_repeat_is_preserving
    old(@path, 'old', local: 'custom guidance')
    safe = '.agents/skills/foundry-plan/SKILL.md'
    old(safe, 'old planning')
    receipt = read(@receipt)
    id = digest
    assert_match(/review pending/, assert_raises(Error) { command.call(apply: id) }.message)
    assert_equal receipt, read(@receipt)
    assert_equal 'custom guidance', read(@path)
    assert_equal incoming(safe), read(safe)
    assert_raises(Error) { install }
    assert_equal 'custom guidance', read("#{directory(id)}/local/#{@path}")
    decisions(id, @path => 'keep_local')
    command.call(resolve: "#{directory(id)}/decisions.json")
    assert_equal incoming_receipt, read(@receipt)
    before = snapshot
    install
    assert_equal before, snapshot
    assert_equal 'custom guidance', read(@path)
    assert_equal 'keep_local', state(id).dig('decisions', @path, 'decision')
  end

  def test_merge_and_upstream_decisions_and_custom_retirement
    second = '.agents/skills/foundry-plan/SKILL.md'
    old(@path, 'old', local: 'custom')
    old(second, 'old', local: 'custom')
    retired = add_retired('retired.txt', customized: true)
    id = digest
    assert_raises(Error) { command.call(apply: id) }
    write(@path, 'reviewed merged instructions')
    decisions(id, @path => 'merged', second => 'use_upstream', retired => 'keep_local')
    command.call(resolve: "#{directory(id)}/decisions.json")
    assert_equal 'reviewed merged instructions', read(@path)
    assert_equal incoming(second), read(second)
    refute JSON.parse(read(@receipt))['files'].key?(retired)
    assert_equal 'custom retired', read(retired)
    command.call(rollback: id)
    assert_equal 'custom', read(@path)
    assert_equal 'custom', read(second)
  end

  def test_bad_and_stale_decisions_do_not_mutate
    old(@path, 'old', local: 'custom')
    id = digest
    assert_raises(Error) { command.call(apply: id) }
    decisions(id, @path => 'invented')
    before = snapshot
    assert_raises(Error) { command.call(resolve: "#{directory(id)}/decisions.json") }
    assert_equal before, snapshot
    decisions(id, @path => 'keep_local')
    customize(@path)
    before = snapshot
    assert_raises(Error) { command.call(resolve: "#{directory(id)}/decisions.json") }
    assert_equal before, snapshot
  end

  def test_later_edit_blocks_whole_rollback
    old(@path, 'old')
    old('.agents/skills/foundry-plan/SKILL.md', 'old plan')
    id = digest
    command.call(apply: id)
    customize(@path)
    before = snapshot
    assert_match(/Later edit/, assert_raises(Error) { command.call(rollback: id) }.message)
    assert_equal before, snapshot
  end

  def test_partial_malformed_legacy_and_unsafe_receipts_are_rejected
    valid = read(@receipt)
    ['{}', '{', JSON.generate('version' => '0.5.0', 'files' => {})].each do |content|
      write(@receipt, content)
      before = snapshot
      assert_raises(Error) { command.call }
      assert_equal before, snapshot
    end
    write(@receipt, valid)
    data = JSON.parse(valid)
    data['files']['../outside'] = 'a' * 64
    write(@receipt, JSON.generate(data))
    assert_raises(Error) { command.call }
    write(@receipt, valid)
    File.unlink(File.join(@root, @path))
    assert_raises(Error) { command.call }
  end

  def test_symlink_and_occupied_new_file_are_rejected
    remove_owned(@path)
    write(@path, 'unowned')
    assert_raises(Error) { command.call }
    File.unlink(File.join(@root, @path))
    File.symlink('/private/tmp', File.join(@root, @path))
    assert_raises(Error) { command.call }
  end

  def test_two_successive_upgrades_keep_accepted_customizations_distinct
    old(@path, 'old', local: 'custom')
    id = digest
    assert_raises(Error) { command.call(apply: id) }
    decisions(id, @path => 'keep_local')
    command.call(resolve: "#{directory(id)}/decisions.json")
    assert_includes command.call, "customized #{@path}"
    with_incoming_change(@path, 'newer upstream') do
      next_id = digest
      refute_equal id, next_id
      assert_raises(Error) { command.call(apply: next_id) }
      assert_equal 'custom', read(@path)
      assert_equal 'pending', state(next_id)['phase']
    end
  end
end
