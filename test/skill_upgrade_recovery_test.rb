# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/generation/skill_upgrade'
require_relative 'support/skill_upgrades'

class SkillUpgradeRecoveryTest < FoundryTest
  include SkillUpgradeHelpers

  Upgrade = RailsAIFoundry::Generation::SkillUpgrade
  Error = RailsAIFoundry::InstallationError

  def setup
    super
    @target = 'agents'
    @path = '.agents/skills/foundry-verify/SKILL.md'
    @receipt = '.foundry/skills/agents.json'
    install
    old(@path, 'old')
    old('.agents/skills/foundry-plan/SKILL.md', 'old plan')
  end

  def test_recovers_process_death_after_destination_write
    id = digest
    crash_at(id, @path, :after)
    assert_equal incoming(@path), read(@path)
    assert_raises(Error) { install }
    assert command.call(apply: id).first.include?('complete')
    assert_equal incoming_receipt, read(@receipt)
  end

  def test_recovers_process_death_before_and_after_receipt_publication
    %i[before after].each do |timing|
      old(@path, "old #{timing}")
      id = digest
      crash_at(id, @receipt, timing)
      assert command.call(apply: id).first.include?('complete')
      assert_equal incoming_receipt, read(@receipt)
    end
  end

  def test_later_edit_blocks_resume_without_any_new_writes
    id = digest
    crash_at(id, '.agents/skills/foundry-plan/SKILL.md', :after)
    customize(@path)
    before = snapshot
    assert_match(/Changed file/, assert_raises(Error) { command.call(apply: id) }.message)
    assert_raises(Error) { command.call(apply: id, pretend: true) }
    assert_equal before, snapshot
  end

  def test_process_death_during_rollback_can_be_resumed
    id = digest
    before = installed
    command.call(apply: id)
    crash_at(id, @path, :after, action: :rollback)
    assert_raises(Error) { command.call(apply: id) }
    command.call(rollback: id)
    assert_equal before, installed
  end

  def test_lock_rejects_concurrent_upgrade_and_ordinary_generation
    ready_reader, ready_writer = IO.pipe
    release_reader, release_writer = IO.pipe
    pid = fork do
      ready_reader.close
      release_writer.close
      Upgrade::Store.new(@root).lock do
        ready_writer.write('ready')
        ready_writer.close
        release_reader.read
      end
      exit! 0
    end
    ready_writer.close
    release_reader.close
    assert_equal 'ready', ready_reader.read
    before = snapshot
    assert_match(/Another skill writer/, assert_raises(Error) { command.call }.message)
    assert_raises(Error) { install }
    assert_equal before, snapshot
  ensure
    release_writer&.close
    Process.wait(pid) if pid
    ready_reader&.close
  end

  def test_disk_failure_preserves_destination_and_can_resume
    id = digest
    original = read(@path)
    fail_write = Module.new do
      define_method(:write_temporary) do |path, *args|
        raise Errno::ENOSPC if path.start_with?('.agents/skills/foundry-verify/SKILL.md')

        super(path, *args)
      end
    end
    pid = fork do
      Upgrade::Store.prepend(fail_write)
      begin
        command.call(apply: id)
      rescue Error => e
        exit! e.message.include?('I/O failure') ? 0 : 2
      end
      exit! 3
    end
    assert Process.wait2(pid).last.success?
    assert_equal original, read(@path)
    command.call(apply: id)
    assert_equal incoming(@path), read(@path)
  end

  def test_recovery_rejects_changed_modes_and_modified_plan
    id = digest
    crash_at(id, @path, :after)
    File.chmod(0o700, File.join(@root, @path))
    assert_raises(Error) { command.call(apply: id) }
    File.chmod(0o644, File.join(@root, @path))
    plan = JSON.parse(read("#{directory(id)}/plan.json"))
    plan['files'][0]['path'] = '../outside'
    write("#{directory(id)}/plan.json", JSON.generate(plan))
    assert_match(/integrity/, assert_raises(Error) { command.call(apply: id) }.message)
  end

  def test_interrupted_resolution_recovers_merged_content
    old(@path, 'older', local: 'custom')
    id = digest
    assert_raises(Error) { command.call(apply: id) }
    write(@path, 'merged')
    decisions(id, @path => 'merged')
    crash_at(id, @receipt, :before, action: :resolve)
    command.call(apply: id)
    assert_equal 'merged', read(@path)
    assert_equal 'complete', state(id)['phase']
  end

  def test_rollback_recovers_resolution_before_edited_content_is_replaced
    old(@path, 'older', local: 'custom')
    id = digest
    assert_raises(Error) { command.call(apply: id) }
    write(@path, 'reviewed local revision')
    decisions(id, @path => 'use_upstream')
    crash_at(id, @path, :before, action: :resolve)
    command.call(rollback: id)
    assert_equal 'custom', read(@path)
    assert_equal 'rolled_back', state(id)['phase']
  end

  def test_edit_during_temporary_write_is_not_overwritten
    selected = @path
    writer = Module.new do
      define_method(:write_temporary) do |path, *args|
        super(path, *args)
        File.binwrite(@file_system.absolute(selected), 'intervening edit') if path.start_with?("#{selected}.upgrade-")
      end
    end
    id = digest
    pid = fork do
      Upgrade::Store.prepend(writer)
      begin
        command.call(apply: id)
      rescue Error => e
        exit! e.message.include?('Changed file blocks replacement') ? 0 : 2
      end
      exit! 3
    end
    assert Process.wait2(pid).last.success?
    assert_equal 'intervening edit', read(@path)
  end

  private

  def crash_at(id, selected, timing, action: :apply)
    crash = Module.new do
      define_method(:replace) do |path, *args|
        exit! 91 if path == selected && timing == :before
        result = super(path, *args)
        exit! 91 if path == selected && timing == :after
        result
      end
    end
    pid = fork do
      Upgrade::Store.prepend(crash)
      value = action == :resolve ? "#{directory(id)}/decisions.json" : id
      command.call(**{ action => value })
      exit! 92
    end
    assert_equal 91, Process.wait2(pid).last.exitstatus
  end
end
