# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/cli'
require_relative 'support/prompt_fixtures'

class PackagePromptCheckTest < FoundryTest
  include PromptFixtures

  def setup
    super
    write('Gemfile', "raise 'Do not execute'\n")
    write('config/application.rb', "raise 'Do not boot'\n")
    write('config/foundry.yml', "workflow:\n  specs: none\n")
    write('packs.yml', "pack_paths:\n- packs/**\n- app/prompts/**\n")
  end

  def test_unconfigured_package_missing_contract_fails
    write('packs/plain/package.yml', "{}\n")
    write('packs/plain/app/prompts/answer/instructions.txt', 'Uncontracted instructions')
    before = snapshot
    status, report, = check
    assert_equal 1, status
    assert_includes report['packages'], 'packs/plain'
    assert_empty report['contexts']
    assert_equal 1, report.dig('prompts', 'files_checked')
    assert_equal(['packs/plain/app/prompts/answer/contract.yml'],
                 report.dig('prompts', 'diagnostics').map { |item| item['file'] })
    assert_equal before, snapshot
  end

  def test_nested_package_cannot_claim_shell_ownership
    pack = 'app/prompts/nested'
    write("#{pack}/package.yml", "{}\n")
    prompt("#{pack}/app/prompts/answer", owner: '.')
    status, report, = check
    assert_includes report['packages'], pack
    assert_equal 1, status
    assert_match(/owner/i, report.dig('prompts', 'diagnostics', 0, 'message'))
    prompt("#{pack}/app/prompts/answer", owner: pack)
    assert_equal 0, check.first
  end

  def test_nested_unconfigured_owner_does_not_inherit_namespace
    write('packs/parent/package.yml', "{}\n")
    write('packs/parent/foundry.yml', "namespace: Parent\n")
    write('packs/parent/child/package.yml', "{}\n")
    prompt('packs/parent/app/prompts/answer', owner: 'packs/parent', agent: 'Parent::Agent')
    prompt('packs/parent/child/app/prompts/answer', owner: 'packs/parent/child')
    status, report, = check
    assert_equal 0, status
    assert_equal 2, report.dig('prompts', 'files_checked')
    prompt('packs/parent/app/prompts/answer', owner: 'packs/parent')
    status, report, = check
    assert_equal 1, status
    assert_equal(['packs/parent/app/prompts/answer/contract.yml'],
                 report.dig('prompts', 'diagnostics').map { |item| item['file'] })
  end

  def test_missing_discovery_and_unsafe_configuration_do_not_fall_back
    prompt('app/prompts/answer', owner: '.')
    write('packs.yml', "pack_paths: /outside\n")
    status, report, error = check
    assert_equal 1, status
    assert_nil report
    assert_includes error, 'application-relative'
    write('packs.yml', "pack_paths: [packs/*]\n")
    failed = Struct.new(:success?).new(false)
    Open3.stub(:capture3, ['', 'discovery fixture failure', failed]) do
      status, report, error = check
      assert_equal 1, status
      assert_nil report
      assert_includes error, 'Upstream pack discovery failed'
    end
  end

  def test_prompt_failure_composes_with_successful_source_check
    write('packs/plain/package.yml', "{}\n")
    write('packs/plain/app/prompts/answer/contract.yml', 'malformed')
    status, report, = check('--sources')
    assert_equal 1, status
    assert report.dig('sources', 'success')
    refute report.dig('prompts', 'success')
  end

  def test_malformed_discovery_output_fails_without_a_partial_report
    successful = Struct.new(:success?).new(true)
    ['not json', '{}', '[null]', '["../outside"]'].each do |output|
      Open3.stub(:capture3, [output, '', successful]) do
        status, report, error = check
        assert_equal 1, status
        assert_nil report
        assert_match(/upstream package/i, error)
      end
    end
  end

  private

  def check(*options)
    output = StringIO.new
    error = StringIO.new
    status = RailsAIFoundry::CLI.new.call(['check', "--root=#{@root}", '--format=json', '--prompts', *options],
                                          stdout: output, stderr: error)
    [status, output.string.empty? ? nil : JSON.parse(output.string), error.string]
  end
end
