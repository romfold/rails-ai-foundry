# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'support/prompt_fixtures'
require 'rails_ai_foundry/conventions/prompt_check'

class PackagePromptSafetyTest < FoundryTest
  include PromptFixtures

  def setup
    super
    @directory = 'packs/plain/app/prompts/answer'
    prompt(@directory, owner: 'packs/plain')
    @checker = RailsAIFoundry::Conventions::PromptCheck.new(@root, packages: ['packs/plain'], contexts: [])
  end

  def test_symlinked_files_directories_and_packages_are_rejected
    write('outside/secret.txt', 'SYNTHETIC PRIVATE CONTENT')
    %w[instructions.txt contract.yml evaluation.yml subdirectory].each do |name|
      path = File.join(@root, @directory, name)
      FileUtils.rm_f(path)
      File.symlink(File.join(@root, 'outside'), path)
      error = assert_raises(RailsAIFoundry::ConfigurationError) { @checker.call }
      assert_includes error.message, 'Symbolic links'
      refute_includes error.message, 'SYNTHETIC PRIVATE CONTENT'
      File.unlink(path)
      prompt(@directory, owner: 'packs/plain')
    end
    File.symlink(File.join(@root, 'packs/plain'), File.join(@root, 'linked'))
    assert_raises(RailsAIFoundry::ConfigurationError) do
      RailsAIFoundry::Conventions::PromptCheck.new(@root, packages: ['linked'], contexts: [])
    end
  end

  def test_invalid_inventory_and_failed_enumeration
    [nil, ['../outside'], ['/outside'], [nil], ["packs/a\0"]].each do |packages|
      assert_raises(RailsAIFoundry::ConfigurationError) do
        RailsAIFoundry::Conventions::PromptCheck.new(@root, packages: packages, contexts: [])
      end
    end
    Dir.stub(:children, ->(*) { raise Errno::EACCES }) do
      error = assert_raises(RailsAIFoundry::ConfigurationError) { @checker.call }
      assert_includes error.message, 'Cannot enumerate'
    end
    write('app/prompts', 'Not a directory')
    assert_raises(RailsAIFoundry::ConfigurationError) { @checker.call }
  end

  def test_disappearing_selected_contract_and_unreadable_reference_fail
    paths = @checker.send(:contract_paths)
    File.unlink(File.join(@root, @directory, 'contract.yml'))
    @checker.stub(:contract_paths, paths) { refute @checker.call['success'] }
    prompt(@directory, owner: 'packs/plain')
    original = File.method(:open)
    replacement = lambda do |path, *args, &block|
      raise Errno::EACCES if path.end_with?('evaluation.yml')

      original.call(path, *args, &block)
    end
    File.stub(:open, replacement) do
      result = @checker.call
      refute result['success']
      assert_includes result['diagnostics'].first['message'], 'Cannot inspect prompt artifact'
    end
  end

  def test_duplicate_keys_and_unsupported_schema_fail
    path = File.join(@directory, 'contract.yml')
    original = File.binread(File.join(@root, path))
    ["#{original}\nschema: 1\n", original.sub('schema: 1', 'schema: 2')].each do |content|
      write(path, content)
      before = snapshot
      refute @checker.call['success']
      assert_equal before, snapshot
    end
  end

  def test_selected_instruction_disappears_after_enumeration
    inventory = @checker.instance_variable_get(:@packages)
    paths = inventory.select('app/prompts') { |path| path.end_with?('instructions.txt') }
    File.unlink(File.join(@root, paths.first))
    inventory.stub(:select, ->(*) { paths }) do
      error = assert_raises(RailsAIFoundry::ConfigurationError) { @checker.call }
      assert_includes error.message, 'Cannot inspect selected prompt file'
    end
  end

  def test_nul_reference_is_a_contract_failure
    path = "#{@directory}/contract.yml"
    data = YAML.safe_load_file(File.join(@root, path))
    write(path, YAML.dump(data.merge('templates' => ["bad\0file"])))
    result = @checker.call
    refute result['success']
    assert_includes result['diagnostics'].first['message'], 'safe paths'
  end
end
