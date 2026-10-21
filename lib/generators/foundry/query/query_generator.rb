# frozen_string_literal: true

require 'rails_ai_foundry/generation/component_generator'

module Foundry
  class QueryGenerator < RailsAIFoundry::Generation::ComponentGenerator
    desc 'Generate a package-owned query in its canonical profile location'

    private

    def component_kind
      'query'
    end
  end
end
