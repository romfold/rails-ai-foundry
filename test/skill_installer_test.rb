# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/generation/skill_installer'

class SkillInstallerTest < FoundryTest
  def test_committed_0_5_catalog_upgrade_preserves_customized_skills_and_receipt
    install
    previous = File.binread(File.join(__dir__, 'fixtures/contracts/skills-0.5.0.json'))
    write('.foundry/skills/agents.json', previous)
    write('.agents/skills/foundry-verify/SKILL.md', 'Application-specific verification')
    before = snapshot
    assert_raises(RailsAIFoundry::InstallationError) { install }
    assert_raises(RailsAIFoundry::InstallationError) { install('agents', pretend: true) }
    assert_equal before, snapshot
  end

  def install(target = 'agents', **options)
    RailsAIFoundry::Generation::SkillInstaller.new(@root, target: target).call(**options)
  end

  def test_both_targets_and_versioned_catalog
    %w[agents claude cursor].each do |target|
      install(target)
      files = Dir[File.join(@root, ".#{target}/skills/*/SKILL.md")]
      assert_equal 8, files.length
      files.each do |path|
        frontmatter = YAML.safe_load(File.read(path).split('---', 3)[1])
        assert_equal File.basename(File.dirname(path)), frontmatter['name']
        assert_equal RailsAIFoundry::VERSION, frontmatter.dig('metadata', 'version')
        refute_empty frontmatter['description']
      end
    end
  end

  def test_installed_resources_and_component_commands_are_available
    install
    RailsAIFoundry::Generation::SkillInstaller::NAMES.each do |name|
      base = File.join(@root, '.agents/skills', name)
      content = File.read(File.join(base, 'SKILL.md'))
      content.scan(%r{\]\((references/[^)]+)\)}).flatten.each do |reference|
        assert File.file?(File.join(base, reference)), "Missing #{name}/#{reference}"
      end
    end
    root = Gem.loaded_specs.fetch('rails_ai_foundry').full_gem_path
    %w[context operation command query model entity value_object policy port repository controller job mailer channel
       agent].each do |kind|
      assert File.file?(File.join(root, "lib/generators/foundry/#{kind}/#{kind}_generator.rb")), kind
    end
  end

  def test_repeat_preserves_customized_skills_and_unrelated_instructions
    write('AGENTS.md', 'Application instructions')
    write('.agents/skills/custom/SKILL.md', 'Unrelated skill')
    install
    write('.agents/skills/foundry-verify/SKILL.md', 'Customized workflow')
    write('.agents/skills/foundry-verify/scripts/verify.rb', '# Customized verification')
    before = snapshot
    install
    assert_equal before, snapshot
  end

  def test_reviewed_catalog_without_scripts_is_not_silently_upgraded
    install
    receipt = JSON.parse(File.read(File.join(@root, '.foundry/skills/agents.json')))
    receipt['files'].delete_if do |path, _|
      removed = path.include?('/scripts/') || path.end_with?('/references/verification.md')
      File.unlink(File.join(@root, path)) if removed
      removed
    end
    write('.foundry/skills/agents.json', "#{JSON.pretty_generate(receipt)}\n")
    before = snapshot
    assert_raises(RailsAIFoundry::InstallationError) { install }
    assert_equal before, snapshot
  end

  def test_conflicts_partial_install_and_changed_receipt_are_preserved
    write('.agents/skills/foundry-verify/SKILL.md', 'Existing file')
    before = snapshot
    assert_raises(RailsAIFoundry::InstallationError) { install }
    assert_equal before, snapshot
    install('claude')
    write('.foundry/skills/claude.json', '{"version":"older"}')
    before = snapshot
    assert_raises(RailsAIFoundry::InstallationError) { install('claude') }
    assert_equal before, snapshot
  end

  def test_pretend_invalid_target_and_symlink_do_not_write
    assert_equal 116, install('agents', pretend: true).length
    assert_empty snapshot
    assert_raises(RailsAIFoundry::InstallationError) { install('../outside') }
    Dir.mktmpdir do |outside|
      File.symlink(outside, File.join(@root, '.agents'))
      assert_raises(RailsAIFoundry::InstallationError) { install }
      assert_empty Dir.children(outside)
    end
  end

  def test_six_skill_catalog_requires_manual_review_for_both_targets
    %w[agents claude].each do |target|
      install(target)
      receipt_path = ".foundry/skills/#{target}.json"
      receipt = JSON.parse(File.read(File.join(@root, receipt_path)))
      receipt['files'].delete_if do |path, _|
        obsolete = path.include?('foundry-adopt-existing-app/') || path.end_with?('/references/adoption.md')
        File.unlink(File.join(@root, path)) if obsolete
        obsolete
      end
      write(receipt_path, "#{JSON.pretty_generate(receipt)}\n")
      write(".#{target}/skills/foundry-verify/SKILL.md", 'Customized legacy guidance')
      before = snapshot
      assert_raises(RailsAIFoundry::InstallationError) { install(target) }
      assert_equal before, snapshot
    end
  end

  def test_previous_seven_skill_catalog_requires_manual_review
    %w[agents claude].each do |target|
      install(target)
      receipt_path = ".foundry/skills/#{target}.json"
      receipt = JSON.parse(File.read(File.join(@root, receipt_path)))
      receipt['files'].delete_if do |path, _|
        obsolete = path.end_with?('/references/ai.md')
        File.unlink(File.join(@root, path)) if obsolete
        obsolete
      end
      write(receipt_path, "#{JSON.pretty_generate(receipt)}\n")
      write(".#{target}/skills/foundry-add-feature/SKILL.md", 'Customized feature workflow')
      before = snapshot
      assert_raises(RailsAIFoundry::InstallationError) { install(target) }
      assert_equal before, snapshot
    end
  end

  def test_seven_skill_catalog_without_planning_requires_manual_review
    install
    receipt = JSON.parse(File.read(File.join(@root, '.foundry/skills/agents.json')))
    receipt['files'].delete_if do |path, _|
      obsolete = path.include?('/foundry-plan/') || path.end_with?('/references/planning.md')
      File.unlink(File.join(@root, path)) if obsolete
      obsolete
    end
    write('.foundry/skills/agents.json', "#{JSON.pretty_generate(receipt)}\n")
    write('.agents/skills/foundry-verify/SKILL.md', 'Customized seven-skill guidance')
    before = snapshot
    assert_raises(RailsAIFoundry::InstallationError) { install }
    assert_equal before, snapshot
  end

  def test_partial_write_is_rolled_back
    installer = RailsAIFoundry::Generation::SkillInstaller.new(@root)
    installer.stub(:write_content, ->(*) { raise Errno::ENOSPC }) do
      assert_raises(RailsAIFoundry::InstallationError) { installer.call }
    end
    assert_empty snapshot
  end

  def test_reused_installer_does_not_roll_back_an_earlier_invocation
    installer = RailsAIFoundry::Generation::SkillInstaller.new(@root)
    installer.call
    File.unlink(File.join(@root, '.agents/skills/foundry-verify/SKILL.md'))
    before = snapshot
    assert_raises(RailsAIFoundry::InstallationError) { installer.call }
    assert_equal before, snapshot
  end
end
