# frozen_string_literal: true

require 'rails_ai_foundry/generation/component_generator'

module Foundry
  class PolicyGenerator < RailsAIFoundry::Generation::ComponentGenerator
    desc 'Generate a package-owned policy in its canonical profile location'

    private

    def component_kind
      'policy'
    end
  end
end
