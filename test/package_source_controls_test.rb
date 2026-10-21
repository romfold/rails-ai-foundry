# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/conventions/source_check'

class PackageSourceControlsTest < FoundryTest
  def test_omission_controls_fail_the_same_coverage_assertion
    shell = 'app/services/reference.rb'
    pack = 'components/plain/app/services/reference.rb'
    [shell, pack].each { |path| write(path, 'RailsAIFoundry::Conventions::Intent') }
    checker = RailsAIFoundry::Conventions::SourceCheck.new(@root, contexts: [], packages: ['components/plain'])
    inventory = checker.instance_variable_get(:@inventory)
    verify_coverage(checker, [shell, pack])
    [[shell], [pack]].each do |faulty_selection|
      inventory.stub(:paths, faulty_selection) do
        error = assert_raises(Minitest::Assertion) { verify_coverage(checker, [shell, pack]) }
        assert_includes error.message, 'Expected: 2'
      end
    end
    verify_coverage(checker, [shell, pack])
  end

  def test_inherited_intent_control_fails_without_requiring_a_command_crash
    write('app/domain/child/app/domain/rule.rb', 'ActiveRecord::Base')
    context = { 'path' => '.', 'namespace' => 'Root', 'profile' => 'domain' }
    checker = RailsAIFoundry::Conventions::SourceCheck.new(@root, contexts: [context],
                                                                  packages: %w[. app/domain/child])
    assert_empty checker.call['diagnostics']
    inventory = checker.instance_variable_get(:@inventory)
    paths = inventory.paths
    inventory.stub(:paths, paths) do
      inventory.stub(:owner, '.') do
        error = assert_raises(Minitest::Assertion) { assert_empty checker.call['diagnostics'] }
        assert_includes error.message, 'source.domain_dependency'
      end
    end
    assert_empty checker.call['diagnostics']
  end

  private

  def verify_coverage(checker, paths)
    result = checker.call
    assert_equal paths.size, result['files_checked']
    assert_equal(paths.sort, result['diagnostics'].map { |item| item['file'] })
    assert_equal ['source.foundry_dependency'], result['diagnostics'].map { |item| item['rule'] }.uniq
  end
end
