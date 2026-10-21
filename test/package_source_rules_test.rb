# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/conventions/source_check'

class PackageSourceRulesTest < FoundryTest
  def test_unconfigured_packages_receive_all_profile_independent_rules
    sources = {
      'models/invoice.rb' => 'class Invoice < ApplicationRecord; end',
      'controllers/chat.rb' => 'RubyLLM.chat.ask("hello")',
      'queries/invoices.rb' => 'Invoice.update_all(active: true)',
      'projections/invoice.rb' => 'Invoice.delete_all',
      'services/transaction.rb' => 'ApplicationRecord.transaction { RubyLLM.chat }',
      'services/tool.rb' => 'RailsAIFoundry::Conventions::Intent',
      'domain/rule.rb' => 'ActiveRecord::Base',
      'models/broken.rb' => 'class Broken <'
    }
    sources.each { |path, content| write("packs/a/app/#{path}", content) }
    result = check(packages: ['packs/a'])
    assert_equal sources.size, result['files_checked']
    refute result['success']
    assert_equal %w[source.delivery_provider source.foundry_dependency source.projection_write
                    source.provider_in_transaction source.query_write source.syntax],
                 result['diagnostics'].map { |item| item['rule'] }.sort
    assert_equal %w[source.projection_write source.provider_in_transaction],
                 result['diagnostics'].select { |item| item['severity'] == 'warning' }.map { |item| item['rule'] }.sort
    context = { 'path' => 'packs/a', 'namespace' => 'A', 'profile' => 'rails_native' }
    assert_equal result, check(packages: ['packs/a'], contexts: [context])
  end

  def test_root_domain_does_not_impose_intent_on_unconfigured_nested_packages
    write('app/domain/rule.rb', 'ActiveRecord::Base')
    write('app/domain/child/app/domain/rule.rb', 'ActiveRecord::Base')
    write('app/domain/child/lib/ignored.rb', 'class Broken <')
    root = { 'path' => '.', 'namespace' => 'Root', 'profile' => 'domain' }
    result = check(packages: %w[. app/domain/child], contexts: [root])
    assert_equal 2, result['files_checked']
    assert_equal(['app/domain/rule.rb'], result['diagnostics'].map { |item| item['file'] })
    child = { 'path' => 'app/domain/child', 'namespace' => 'Child', 'profile' => 'domain' }
    assert_equal 2, check(packages: %w[. app/domain/child], contexts: [root, child])['diagnostics'].size
    child['profile'] = 'modular'
    assert_equal result, check(packages: %w[. app/domain/child], contexts: [root, child])
  end

  def test_explicit_model_constants_do_not_confuse_sibling_namespaces
    write('packs/a/app/models/a/invoice.rb', 'class A::Invoice < ApplicationRecord; end')
    write('packs/ab/app/models/ab/invoice.rb', 'class AB::Invoice; end')
    write('packs/ab/app/queries/report.rb', 'AB::Invoice.create; A::Invoice.update_all(active: true)')
    context = { 'path' => 'packs/a', 'namespace' => 'A', 'profile' => 'domain' }
    result = check(packages: %w[packs/a packs/ab], contexts: [context])
    assert_equal(['source.query_write'], result['diagnostics'].map { |item| item['rule'] })
    write('packs/ab/app/queries/report.rb', 'Invoice.create; AB::Invoice.create')
    assert_empty check(packages: %w[packs/a packs/ab], contexts: [context])['diagnostics']
  end

  def test_empty_source_and_native_literals_remain_successful
    assert_equal 0, check(packages: ['packs/empty'])['files_checked']
    write('packs/a/app/services/native.rb', <<~RUBY)
      # RailsAIFoundry::Conventions::Intent
      TEXT = 'RubyLLM.chat'
      Other::RailsAIFoundry::Operation
      ApplicationRecord.transaction { Object.new }
    RUBY
    assert check(packages: ['packs/a'])['success']
    assert_empty check(packages: ['packs/a'])['diagnostics']
  end

  def test_selected_source_disappearance_and_read_failure_are_explicit
    write('packs/a/app/services/native.rb', 'Object')
    checker = RailsAIFoundry::Conventions::SourceCheck.new(@root, packages: ['packs/a'], contexts: [])
    files = checker.instance_variable_get(:@files)
    files.stub(:read, nil) do
      error = assert_raises(RailsAIFoundry::ConfigurationError) { checker.call }
      assert_includes error.message, 'Source disappeared'
    end
    files.stub(:read, ->(*) { raise Errno::EACCES }) do
      error = assert_raises(RailsAIFoundry::ConfigurationError) { checker.call }
      assert_equal 'Cannot read source: packs/a/app/services/native.rb', error.message
    end
  end

  private

  def check(packages:, contexts: [])
    RailsAIFoundry::Conventions::SourceCheck.new(@root, packages: packages, contexts: contexts).call
  end
end
