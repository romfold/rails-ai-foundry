# frozen_string_literal: true

require 'rails_ai_foundry/generation/component_generator'

module Foundry
  class RepositoryGenerator < RailsAIFoundry::Generation::ComponentGenerator
    desc 'Generate a package-owned repository in its canonical profile location'

    private

    def component_kind
      'repository'
    end
  end
end
