# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/conventions/application_config'
require 'rails_ai_foundry/conventions/context_installer'

class ApplicationConfigTest < FoundryTest
  def test_workload_defaults_and_patterns_are_independent
    RailsAIFoundry::Conventions::ApplicationConfig::WORKLOADS.each do |workload|
      write('config/foundry.yml', YAML.dump('workload' => workload, 'defaults' => {
                                              'profile' => 'rails_native', 'patterns' => { 'events' => 'event_sourced' }
                                            }))
      configuration = RailsAIFoundry::Conventions::ApplicationConfig.new(@root)
      assert_equal workload, configuration.workload
      assert_equal 'rails_native', configuration.defaults['profile']
      assert_equal({ 'events' => 'event_sourced' }, configuration.defaults['patterns'])
    end
  end

  def test_invalid_known_settings_and_duplicate_topology_are_rejected
    [{ 'workload' => 'high_load' }, { 'defaults' => [] }, { 'checks' => true }, { 'adoption' => [] },
     { 'defaults' => { 'profile' => 'unsupported' } }, { 'defaults' => { 'namespace' => 'Shared' } },
     { 'defaults' => { 'patterns' => { 'cqrs' => 'heavy' } } }, { 'public_path' => 'app/public' }].each do |data|
      write('config/foundry.yml', YAML.dump(data))
      before = snapshot
      assert_raises(RailsAIFoundry::ConfigurationError) do
        RailsAIFoundry::Conventions::ApplicationConfig.new(@root)
      end
      assert_equal before, snapshot
    end
  end

  def test_generation_uses_defaults_and_explicit_profile_without_promoting_patterns
    write('Gemfile', '# consumer')
    write('config/application.rb', "raise 'must not boot'")
    write('config/foundry.yml', YAML.dump('defaults' => {
                                            'profile' => 'domain', 'patterns' => { 'events' => 'integration',
                                                                                   'cqrs' => 'queries' }
                                          }))
    RailsAIFoundry::Conventions::ContextInstaller.new(@root, 'billing').call
    RailsAIFoundry::Conventions::ContextInstaller.new(@root, 'search', profile: 'modular').call
    billing = RailsAIFoundry::Conventions::Intent.load(@root, 'packs/billing')
    search = RailsAIFoundry::Conventions::Intent.load(@root, 'packs/search')
    assert_equal 'domain', billing.profile
    assert_equal 'modular', search.profile
    assert_equal billing.data['patterns'], search.data['patterns']
    assert_equal({ 'events' => 'integration', 'cqrs' => 'queries' }, search.data['patterns'])
  end
end
