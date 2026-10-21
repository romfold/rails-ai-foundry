# frozen_string_literal: true

require_relative 'test_helper'
require 'rails_ai_foundry/conventions/assessment'

class AdoptionGuidanceTest < FoundryTest
  def setup
    super
    write('Gemfile', "source 'https://rubygems.org'\n")
    write('config/application.rb', "raise 'Do not boot during assessment'\n")
  end

  def test_existing_custom_packages_receive_specific_preserving_guidance
    write('packs.yml', "pack_paths:\n  - components/*\n")
    write('components/knowledge/package.yml', 'enforce_dependencies: true')
    write('components/knowledge/foundry.yml', "namespace: Knowledge\nprofile: modular\n")
    write('components/shared/package.yml', 'enforce_dependencies: true')
    write('openspec/config.yaml', "schema: spec-driven\n")
    write('openspec/changes/archive/old/proposal.md', 'Accepted history')
    before = snapshot
    result = RailsAIFoundry::Conventions::Assessment.new(@root).call(adoption: true)
    guidance = result.fetch('next_steps').join("\n")
    assert_includes guidance, 'foundry plan refactor --context=components/knowledge'
    assert_includes guidance, 'components/shared/foundry.yml'
    assert_includes guidance, 'Preserve initialized openspec'
    refute_includes guidance, 'foundry setup'
    assert_equal before, snapshot
  end

  def test_plain_app_recommends_one_boundary_and_missing_workflow_setup
    result = RailsAIFoundry::Conventions::Assessment.new(@root).call(adoption: true)
    guidance = result.fetch('next_steps').join("\n")
    assert_includes guidance, 'Choose one business boundary in app/'
    assert_includes guidance, 'foundry setup --specs=openspec'
    refute result.fetch('workflow_initialized')
  end

  def test_explicit_none_needs_no_workflow_initialization
    result = RailsAIFoundry::Conventions::Assessment.new(@root).call(adoption: true, specs: 'none')
    guidance = result.fetch('next_steps').join("\n")
    assert_includes guidance, 'Workflow none is selected'
    refute_includes guidance, 'foundry setup'
  end
end
