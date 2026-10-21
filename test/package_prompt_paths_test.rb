# frozen_string_literal: true

require_relative 'test_helper'
require_relative 'support/prompt_fixtures'
require 'rails_ai_foundry/conventions/prompt_check'

class PackagePromptPathsTest < FoundryTest
  include PromptFixtures

  def test_standard_custom_nested_overlapping_and_root_coverage
    owners = %w[. components/a components/a/child app/prompts/embedded]
    owners.each { |pack| prompt(File.join(pack, 'app/prompts/answer'), owner: pack) }
    write('components/a/test/prompts/instructions.txt', 'Excluded')
    write('components/a/lib/prompts/contract.yml', 'Excluded')
    write('app/agents/instructions.txt', 'Excluded')
    checker = check_for([*owners, './components/a', 'components/empty'])
    expected = owners.map { |pack| File.join(pack, 'app/prompts/answer/contract.yml').delete_prefix('./') }.sort
    assert_equal expected, checker.send(:contract_paths)
    assert_equal checker.call, checker.call
    assert checker.call['success']
    assert_equal 4, checker.call['files_checked']
  end

  def test_packages_at_and_above_prompt_roots_are_not_parent_prompts
    %w[app app/prompts packs/parent/app/prompts].each do |pack|
      write("#{pack}/instructions.txt", 'Not in this package prompt root')
      prompt("#{pack}/app/prompts/answer", owner: pack)
    end
    checker = check_for(%w[app app/prompts packs/parent packs/parent/app/prompts])
    assert checker.call['success']
    assert_equal 3, checker.call['files_checked']
  end

  def test_recognition_and_missing_contract_counts
    assert_equal 0, check_for(['packs/empty']).call['files_checked']
    write('packs/plain/app/prompts/other/custom.erb', 'Requires explicit contract to be selected')
    write('packs/plain/app/prompts/answer/instructions.txt', 'First')
    write('packs/plain/app/prompts/answer/instructions.txt.erb', 'Second')
    checker = check_for(['packs/plain'])
    result = checker.call
    assert_equal 1, result['files_checked']
    refute result['success']
    prompt('packs/plain/app/prompts/answer', owner: 'packs/plain')
    assert checker.call['success']
    prompt('packs/plain/app/prompts/other', owner: 'packs/plain')
    File.rename(File.join(@root, 'packs/plain/app/prompts/other/instructions.txt'),
                File.join(@root, 'packs/plain/app/prompts/other/custom.erb'))
    contract = 'packs/plain/app/prompts/other/contract.yml'
    data = YAML.safe_load_file(File.join(@root, contract))
    write(contract, YAML.dump(data.merge('templates' => ['custom.erb'])))
    assert checker.call['success']
    assert_equal 2, checker.call['files_checked']
  end

  def test_references_cannot_enter_nested_package
    directory = 'packs/parent/app/prompts/answer'
    nested = "#{directory}/artifacts"
    prompt(directory, owner: 'packs/parent')
    write("#{nested}/evaluation.yml", 'Offline fixture')
    data = YAML.safe_load_file(File.join(@root, directory, 'contract.yml'))
    write("#{directory}/contract.yml", YAML.dump(data.merge('evaluations' => ['artifacts/evaluation.yml'])))
    assert check_for(['packs/parent']).call['success']
    result = check_for(['packs/parent', nested]).call
    refute result['success']
    assert_includes result['diagnostics'].first['message'], 'ownership boundary'
  end

  def test_root_configuration_and_sibling_ownership
    prompt('app/prompts/answer', owner: '.', agent: 'Root::Agent')
    contexts = [{ 'path' => '.', 'namespace' => 'Root' }]
    assert check_for(['.'], contexts: contexts).call['success']
    prompt('app/prompts/answer', owner: '.')
    refute check_for(['.'], contexts: contexts).call['success']
    prompt('packs/ab/app/prompts/answer', owner: 'packs/a')
    result = check_for(%w[packs/a packs/ab]).call
    assert_equal(['packs/ab/app/prompts/answer/contract.yml'], result['diagnostics'].map { |item| item['file'] })
  end

  private

  def check_for(packages, contexts: [])
    RailsAIFoundry::Conventions::PromptCheck.new(@root, packages: packages, contexts: contexts)
  end
end
