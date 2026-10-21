# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/conventions/context_installer'
require 'rails_ai_foundry/conventions/component_installer'

class NativeContextTest < FoundryTest
  def setup
    super
    write('Gemfile', '# Development consumer')
    write('config/application.rb', "raise 'must not boot'\n")
  end

  def test_upstream_creation_and_repeat_preserve_business_code
    installer = context('billing')
    before = snapshot
    assert_includes installer.call(pretend: true), 'would create packs/billing/foundry.yml'
    assert_equal before, snapshot
    installer.call
    topology = YAML.safe_load_file(File.join(@root, 'packs/billing/package.yml'))
    assert topology['enforce_dependencies']
    assert topology['enforce_privacy']
    refute topology['enforce_layers']
    write('packs/billing/app/models/billing/invoice.rb', '# User implementation')
    write('packs/billing/README.md', '# User documentation')
    before = snapshot
    installer.call
    assert_equal before, snapshot
    assert_raises(RailsAIFoundry::InstallationError) { context('billing', profile: 'domain').call }
  end

  def test_custom_roots_namespace_and_independent_patterns
    write('packs.yml', "pack_paths:\n- components/*\n")
    context('search', path: 'components/search', namespace: 'Platform::Search', kind: 'platform').call
    intent = YAML.safe_load_file(File.join(@root, 'components/search/foundry.yml'))
    assert_equal 'rails_native', intent['profile']
    assert_equal 'none', intent.dig('patterns', 'events')
    assert_equal 'Platform::Search', intent['namespace']
    refute File.exist?(File.join(@root, 'packs'))
    before = snapshot
    assert_raises(RailsAIFoundry::InstallationError) { context('other').call }
    assert_equal before, snapshot
  end

  def test_profile_first_placement_defines_ordinary_ruby_namespaces
    { 'rails_native' => ['operations/billing/charge.rb', 'Billing::Charge'],
      'modular' => ['commands/billing/charge.rb', 'Billing::Charge'],
      'domain' => ['application/billing/commands/charge.rb',
                   'Billing::Commands::Charge'] }.each do |profile, (path, constant)|
      intent = RailsAIFoundry::Conventions::Intent.new('namespace' => 'Billing', 'profile' => profile)
      template = RailsAIFoundry::Conventions::ComponentTemplates.new(intent, 'charge', 'command')
      assert_equal "app/#{path}", template.path
      assert_equal constant, template.constant
      assert_includes template.source, '< Dry::Operation'
      refute_includes template.source, 'RailsAIFoundry::'
    end
  end

  def test_components_refuse_partial_scaffolds_and_preserve_edited_implementations
    context('billing', profile: 'domain').call
    installer = RailsAIFoundry::Conventions::ComponentInstaller.new(@root, 'charge', context: 'billing',
                                                                                     kind: 'command')
    installer.call
    file = 'packs/billing/app/application/billing/commands/charge.rb'
    write(file, '# User implementation')
    before = snapshot
    installer.call
    assert_equal before, snapshot
    File.unlink(File.join(@root, 'packs/billing/.foundry/components/command/charge.yml'))
    assert_raises(RailsAIFoundry::InstallationError) { installer.call }
    assert_equal '# User implementation', File.read(File.join(@root, file))
  end

  def test_rejects_unsupported_profiles_and_unsafe_paths_before_creation
    before = snapshot
    assert_raises(RailsAIFoundry::ConfigurationError) { context('billing', profile: 'unsupported').call }
    assert_raises(RailsAIFoundry::ConfigurationError) { context('billing', path: '../billing').call }
    assert_raises(RailsAIFoundry::ConfigurationError) { context('billing;exit').call }
    assert_equal before, snapshot
  end

  def test_namespace_collision_does_not_create_another_owner
    context('billing').call
    before = snapshot
    assert_raises(RailsAIFoundry::ConfigurationError) { context('payments', namespace: 'Billing').call }
    assert_equal before, snapshot
  end

  def test_component_roles_cannot_generate_the_same_modular_constant
    context('billing', profile: 'modular').call
    RailsAIFoundry::Conventions::ComponentInstaller.new(@root, 'quote', context: 'billing', kind: 'operation').call
    write('packs/billing/app/operations/billing/quote.rb', '# Implemented business behavior')
    before = snapshot
    installer = RailsAIFoundry::Conventions::ComponentInstaller.new(@root, 'quote', context: 'billing', kind: 'model')
    [false, true].each do |pretend|
      error = assert_raises(RailsAIFoundry::InstallationError) { installer.call(pretend: pretend) }
      assert_includes error.message, 'Billing::Quote is already generated'
      assert_equal before, snapshot
    end
  end

  def test_domain_categories_allow_distinct_constants_with_the_same_leaf_name
    context('billing', profile: 'domain').call
    %w[command query].each do |kind|
      installer = RailsAIFoundry::Conventions::ComponentInstaller.new(@root, 'quote', context: 'billing', kind: kind)
      installer.call
      before = snapshot
      installer.call
      assert_equal before, snapshot
    end
  end

  private

  def context(name, **options)
    RailsAIFoundry::Conventions::ContextInstaller.new(@root, name, **options)
  end
end
