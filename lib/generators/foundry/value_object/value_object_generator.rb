# frozen_string_literal: true

require 'rails_ai_foundry/generation/component_generator'

module Foundry
  class ValueObjectGenerator < RailsAIFoundry::Generation::ComponentGenerator
    desc 'Generate a package-owned value_object in its canonical profile location'

    private

    def component_kind
      'value_object'
    end
  end
end
