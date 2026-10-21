# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/conventions/refactor'

class PackageRefactorTest < FoundryTest
  def setup
    super
    write('packs.yml', "pack_paths:\n- .\n- components/**\n")
    package('components/billing', 'Billing')
    package('components/billing/child')
  end

  def test_nested_syntax_is_excluded_with_or_without_intent
    write('components/billing/child/test/broken.rb', 'class Broken <')
    [nil, 'Child'].each do |namespace|
      package('components/billing/child', namespace)
      before = snapshot
      result = assess
      assert result.fetch('complete')
      assert_empty result.fetch('findings')
      assert_equal before, snapshot
    end
  end

  def test_configured_root_applies_its_own_rules
    package('.', 'Shell', 'domain')
    write('app/domain/rule.rb', 'Rails.logger')
    write('components/billing/test/broken.rb', 'class Broken <')
    result = assess('Shell')
    assert result.fetch('complete')
    assert_equal(['app/domain/rule.rb'], result.fetch('findings').map { |item| item['file'] })
    assert_equal 'source.domain_dependency', result.fetch('findings').first['rule']
  end

  def test_non_app_sources_and_non_root_vendor_remain_selected
    %w[test lib vendor].each { |dir| write("components/billing/#{dir}/broken.rb", 'class Broken <') }
    result = assess
    refute result.fetch('complete')
    assert_equal(%w[lib test vendor].map { |dir| "components/billing/#{dir}/broken.rb" },
                 result.fetch('findings').map { |item| item['file'] })
  end

  def test_child_models_do_not_supply_parent_evidence
    write('components/billing/child/app/models/record.rb', 'class Billing::Record < ApplicationRecord; end')
    write('components/billing/app/queries/query.rb', 'Billing::Record.update_all(active: true)')
    assert_empty assess.fetch('findings')
    write('components/billing/app/models/record.rb', 'class Billing::Record < ApplicationRecord; end')
    assert_equal(['source.query_write'], assess.fetch('findings').map { |item| item['rule'] })
  end

  def test_root_scope_includes_source_and_excludes_generated_trees
    package('.', 'Shell')
    %w[app lib test spec config db script].each { |dir| write("#{dir}/broken.rb", 'class Broken <') }
    write('root.rb', 'class Broken <')
    %w[vendor node_modules tmp log storage coverage .hidden].each do |dir|
      write("#{dir}/ignored.rb", 'class Broken <')
    end
    write('components/billing/.hidden/ignored.rb', 'class Broken <')
    result = assess('Shell')
    expected = %w[app/broken.rb config/broken.rb db/broken.rb lib/broken.rb root.rb script/broken.rb
                  spec/broken.rb test/broken.rb]
    assert_equal(expected, result.fetch('findings').map { |item| item['file'] })
    assert_empty assess.fetch('findings')
  end

  def test_selection_and_ambiguity_are_preserved
    package('components/billing_extra', 'Extra')
    write('components/billing_extra/lib/broken.rb', 'class Broken <')
    assert_empty assess('components/billing').fetch('findings')
    assert_empty assess('billing').fetch('findings')
    assert_raises(RailsAIFoundry::ConfigurationError) { assess('child') }
    package('components/other/billing', 'Other')
    assert_raises(RailsAIFoundry::ConfigurationError) { assess('billing') }
    assert_empty assess('Billing').fetch('findings')
  end

  private

  def package(path, namespace = nil, profile = 'modular')
    write("#{path}/package.yml", "{}\n")
    write("#{path}/foundry.yml", "namespace: #{namespace}\nprofile: #{profile}\n") if namespace
  end

  def assess(context = 'Billing')
    RailsAIFoundry::Conventions::Refactor.new(@root).call(context: context)
  end
end
