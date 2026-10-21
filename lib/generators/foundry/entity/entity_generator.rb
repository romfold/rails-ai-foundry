# frozen_string_literal: true

require 'rails_ai_foundry/generation/component_generator'

module Foundry
  class EntityGenerator < RailsAIFoundry::Generation::ComponentGenerator
    desc 'Generate a package-owned entity in its canonical profile location'

    private

    def component_kind
      'entity'
    end
  end
end
