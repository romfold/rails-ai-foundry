# frozen_string_literal: true

require_relative '../test/test_helper'
require 'shellwords'

# Separate lane: init uses upstream bundled assets, but installing the tools is an explicit prerequisite.
class UpstreamSetupTest < FoundryTest
  def test_native_workflows_in_a_real_rails_generated_consumer
    exercise('codex', '.agents')
  end

  def test_claude_integration
    exercise('claude', '.claude')
  end

  def test_cursor_integration
    exercise('cursor', '.cursor')
  end

  private

  def exercise(agent, directory)
    rails = Gem.bin_path('railties', 'rails')
    run!(RbConfig.ruby, rails, 'new', 'consumer', '--skip-bundle', '--skip-git', '--skip-dev-gems')
    root = File.join(@root, 'consumer')
    write('openspec/config.yaml', 'schema: spec-driven')
    foundry = File.expand_path('../exe/foundry', __dir__)
    run!(RbConfig.ruby, foundry, 'setup', "--root=#{root}", '--greenfield', "--agent=#{agent}")
    assert File.file?(File.join(root, '.specify/memory/constitution.md'))
    assert File.file?(File.join(root, "#{directory}/skills/speckit-converge/SKILL.md"))
    run!(RbConfig.ruby, foundry, 'setup', "--root=#{root}", '--specs=openspec', "--agent=#{agent}")
    assert File.file?(File.join(root, 'openspec/config.yaml'))
    assert File.file?(File.join(root, "#{directory}/skills/openspec-apply-change/SKILL.md"))
    before = snapshot
    run!(RbConfig.ruby, foundry, 'setup', "--root=#{root}")
    assert_equal before, snapshot
    run!(RbConfig.ruby, foundry, 'setup', "--root=#{root}", '--specs=none')
    assert File.file?(File.join(root, '.specify/memory/constitution.md'))
    assert File.file?(File.join(root, 'openspec/config.yaml'))
    assert_equal 'none', YAML.safe_load_file(File.join(root, 'config/foundry.yml')).dig('workflow', 'specs')
  end

  def run!(*arguments)
    puts "[workflow acceptance] #{arguments.shelljoin}"
    output, error, status = Open3.capture3(*arguments, chdir: @root)
    puts output unless output.empty?
    warn error unless error.empty?
    assert status.success?, "#{output}\n#{error}"
  end
end
