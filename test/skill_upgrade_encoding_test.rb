# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/generation/skill_upgrade'
require_relative 'support/skill_upgrades'

class SkillUpgradeEncodingTest < FoundryTest
  include SkillUpgradeHelpers

  def test_upgrade_and_rollback_preserve_bytes_with_rails_internal_encoding
    @target = 'agents'
    @receipt = '.foundry/skills/agents.json'
    path = '.agents/skills/foundry-verify/references/verification.md'
    install
    old(path, 'Previous instructions — é')
    original = installed
    internal_encoding = Encoding.default_internal
    Encoding.default_internal = Encoding::UTF_8
    with_incoming_change(path, 'New instructions — λ') do
      id = digest
      command.call(apply: id)
      assert_equal 'New instructions — λ'.b, read(path)
      command.call(rollback: id)
      assert_equal original, installed
    end
  ensure
    Encoding.default_internal = internal_encoding
  end
end
