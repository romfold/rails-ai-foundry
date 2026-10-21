# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/conventions/contexts'
require 'rails_ai_foundry/cli'

class ContextDiscoveryTest < FoundryTest
  def test_rejects_misplaced_intent_even_with_canonical_sidecar
    write('packs/billing/package.yml', "dependencies: []\n")
    write('packs/billing/config/foundry.yml', "profile: modular\n")
    [false, true].each do |canonical|
      write('packs/billing/foundry.yml', "namespace: Billing\n") if canonical
      error = assert_raises(RailsAIFoundry::ConfigurationError) do
        RailsAIFoundry::Conventions::Contexts.new(@root).all
      end
      assert_includes error.message, 'packs/billing/config/foundry.yml'
      assert_includes error.message, 'Use packs/billing/foundry.yml beside package.yml'
      assert_equal "profile: modular\n", File.read(File.join(@root, 'packs/billing/config/foundry.yml'))
    end
  end

  def test_misplaced_custom_root_and_valid_application_config
    write('packs.yml', "pack_paths: ['components/*']\n")
    write('package.yml', "dependencies: []\n")
    write('config/foundry.yml', "workflow:\n  specs: none\n")
    assert_empty RailsAIFoundry::Conventions::Contexts.new(@root).all
    write('components/billing/package.yml', "dependencies: []\n")
    write('components/billing/config/foundry.yml', "profile: modular\n")
    assert_raises(RailsAIFoundry::ConfigurationError) do
      RailsAIFoundry::Conventions::Contexts.new(@root).all
    end
  end

  def test_canonical_intent_rejects_missing_namespace_and_application_keys
    write('packs/billing/package.yml', "dependencies: []\n")
    ["profile: modular\n", "namespace: Billing\nworkflow:\n  specs: none\n"].each do |intent|
      write('packs/billing/foundry.yml', intent)
      assert_raises(RailsAIFoundry::ConfigurationError) do
        RailsAIFoundry::Conventions::Contexts.new(@root).all
      end
    end
  end

  def test_misplaced_intent_uses_existing_cli_error_status
    write('Gemfile', "source 'https://rubygems.org'\n")
    write('config/application.rb', "raise 'must not boot'\n")
    write('packs/billing/package.yml', "dependencies: []\n")
    write('packs/billing/config/foundry.yml', "namespace: Billing\n")
    output = StringIO.new
    error = StringIO.new
    arguments = ['check', "--root=#{@root}", '--format=json']
    assert_equal 1, RailsAIFoundry::CLI.new.call(arguments, stdout: output, stderr: error)
    assert_includes error.string, 'Use packs/billing/foundry.yml'
    assert_empty output.string
  end

  def test_upstream_discovers_custom_roots_and_nested_packs
    write('packs.yml', "pack_paths:\n  - components/*\n  - components/*/*\n")
    %w[components/billing components/platform/search].each do |path|
      write("#{path}/package.yml", "dependencies: []\n")
    end
    write('components/billing/foundry.yml', "namespace: Billing\nprofile: domain\n")
    write('components/platform/search/foundry.yml', "namespace: Platform::Search\nkind: platform\n")
    result = RailsAIFoundry::Conventions::Contexts.new(@root).all
    assert_equal %w[components/billing components/platform/search], result.keys
    assert_equal 'domain', result['components/billing'].profile
  end

  def test_plain_upstream_packs_are_allowed_without_intent
    write('packs/billing/package.yml', "dependencies: []\n")
    assert_empty RailsAIFoundry::Conventions::Contexts.new(@root).all
    write('packs/billing/package.yml', "metadata:\n  foundry: {}\n")
    assert_empty RailsAIFoundry::Conventions::Contexts.new(@root).all
  end

  def test_discovery_does_not_leak_between_roots
    write('packs/billing/package.yml', "dependencies: []\n")
    write('packs/billing/foundry.yml', "namespace: Billing\n")
    write('child/packs/other/package.yml', "dependencies: []\n")
    write('child/packs/other/foundry.yml', "namespace: Other\n")
    assert_equal ['packs/billing'], RailsAIFoundry::Conventions::Contexts.new(@root).all.keys
    child = RailsAIFoundry::Conventions::Contexts.new(File.join(@root, 'child'))
    assert_equal ['packs/other'], child.all.keys
  end

  def test_rejects_unsafe_globs_and_duplicate_namespaces
    write('packs.yml', "pack_paths: ['../*']\n")
    assert_raises(RailsAIFoundry::ConfigurationError) { RailsAIFoundry::Conventions::Contexts.new(@root).all }
    write('packs.yml', "pack_paths: ['packs/*']\n")
    %w[a b].each do |name|
      write("packs/#{name}/package.yml", "dependencies: []\n")
      write("packs/#{name}/foundry.yml", "namespace: Same\n")
    end
    assert_raises(RailsAIFoundry::ConfigurationError) do
      RailsAIFoundry::Conventions::Contexts.new(@root).find('Same')
    end
  end
end
