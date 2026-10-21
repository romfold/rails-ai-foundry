# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/conventions/intent'

class ContextIntentTest < FoundryTest
  def intent(**options)
    RailsAIFoundry::Conventions::Intent.new({ 'namespace' => 'Knowledge' }.merge(options.transform_keys(&:to_s)))
  end

  def test_defaults_and_all_independent_combinations
    assert_equal 'rails_native', intent.profile
    assert_equal({ 'events' => 'none', 'cqrs' => 'none' }, intent.data['patterns'])
    %w[rails_native modular domain].product(%w[none integration event_sourced],
                                            %w[none queries read_model]) do |p, e, q|
      result = intent(profile: p, patterns: { 'events' => e, 'cqrs' => q })
      assert_equal p, result.profile
      assert_equal({ 'events' => e, 'cqrs' => q }, result.data['patterns'])
    end
  end

  def test_unknown_profile_diagnostics
    error = assert_raises(RailsAIFoundry::ConfigurationError) { intent(profile: 'unsupported') }
    assert_includes error.message, 'rails_native'
    error = assert_raises(RailsAIFoundry::ConfigurationError) { intent(profile: 'event_sourced') }
    assert_includes error.message, 'Unknown profile'
  end

  def test_rejects_invalid_shapes_without_promoting_profile
    [{ dependencies: [] }, { schema: '1' }, { kind: 'unknown' }, { namespace: 'knowledge' },
     { patterns: [] }, { patterns: { 'events' => 'lite' } }, { capabilities: ['rag'] },
     { capabilities: { 'llm' => {} } }].each do |attributes|
      assert_raises(RailsAIFoundry::ConfigurationError) { intent(**attributes) }
    end
    result = intent(capabilities: { 'llm' => { 'adapter' => 'ruby_llm' } })
    assert_equal 'rails_native', result.profile
  end

  def test_loads_adjacent_intent_without_executing_package_ruby
    write('components/knowledge/package.yml', "dependencies: []\n")
    write('components/knowledge/foundry.yml', "schema: 1\nnamespace: Knowledge\n")
    write('components/knowledge/app/models/knowledge.rb', "raise 'must not execute'\n")
    result = RailsAIFoundry::Conventions::Intent.load(@root, 'components/knowledge')
    assert_equal 'Knowledge', result.namespace
    write('components/knowledge/package.yml', "metadata:\n  foundry:\n    profile: modular\n")
    assert_equal 'rails_native', RailsAIFoundry::Conventions::Intent.load(@root, 'components/knowledge').profile
  end
end
