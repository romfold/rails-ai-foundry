# frozen_string_literal: true

require 'rails_ai_foundry/generation/component_generator'

module Foundry
  class ModelGenerator < RailsAIFoundry::Generation::ComponentGenerator
    desc 'Generate a package-owned model in its canonical profile location'

    private

    def component_kind
      'model'
    end
  end
end
