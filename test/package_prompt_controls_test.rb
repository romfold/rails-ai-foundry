# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'support/prompt_fixtures'
require 'rails_ai_foundry/conventions/prompt_check'

class PackagePromptControlsTest < FoundryTest
  include PromptFixtures

  def test_omitted_package_control_is_rejected
    paths = %w[app/prompts/answer/contract.yml packs/plain/app/prompts/answer/contract.yml]
    paths.each { |path| write(path, 'invalid contract') }
    checker = checker_for(['packs/plain'])
    verify_inventory(checker, paths)
    checker.stub(:contract_paths, paths.take(1)) do
      assert_raises(Minitest::Assertion) { verify_inventory(checker, paths) }
    end
    verify_inventory(checker, paths)
  end

  def test_inherited_namespace_control_is_rejected
    pack = 'packs/parent/child'
    prompt("#{pack}/app/prompts/answer", owner: pack)
    valid = checker_for(['packs/parent', pack], [{ 'path' => 'packs/parent', 'namespace' => 'Parent' }])
    assert valid.call['success']
    faulty = checker_for(['packs/parent', pack], [{ 'path' => pack, 'namespace' => 'Parent' }])
    assert_raises(Minitest::Assertion) { assert faulty.call['success'] }
    assert valid.call['success']
  end

  def test_parent_ownership_and_missing_artifact_controls_are_rejected
    directory = 'app/prompts/nested/app/prompts/answer'
    prompt(directory, owner: '.')
    checker = checker_for(['app/prompts/nested'])
    contract = contract_for(checker)
    verify_failure(checker, 'owner')
    contract.stub(:validate_owner!, nil) do
      RailsAIFoundry::Conventions::PromptContract.stub(:new, ->(*) { contract }) do
        assert_raises(Minitest::Assertion) { verify_failure(checker, 'owner') }
      end
    end
    verify_failure(checker, 'owner')
    prompt(directory, owner: 'app/prompts/nested')
    File.unlink(File.join(@root, directory, 'evaluation.yml'))
    verify_failure(checker, 'Missing')
    contract.stub(:validate_file!, nil) do
      RailsAIFoundry::Conventions::PromptContract.stub(:new, ->(*) { contract }) do
        assert_raises(Minitest::Assertion) { verify_failure(checker, 'Missing') }
      end
    end
    verify_failure(checker, 'Missing')
    prompt(directory, owner: 'app/prompts/nested')
    assert checker.call['success']
  end

  private

  def checker_for(packages, contexts = [])
    RailsAIFoundry::Conventions::PromptCheck.new(@root, packages: packages, contexts: contexts)
  end

  def contract_for(checker)
    RailsAIFoundry::Conventions::PromptContract.new(RailsAIFoundry::Conventions::Files.new(@root), [],
                                                    packages: checker.instance_variable_get(:@packages))
  end

  def verify_inventory(checker, paths)
    result = checker.call
    assert_equal paths.size, result['files_checked']
    assert_equal(paths.sort, result['diagnostics'].map { |item| item['file'] })
  end

  def verify_failure(checker, message)
    result = checker.call
    refute result['success']
    assert_includes result['diagnostics'].first['message'], message
  end
end
