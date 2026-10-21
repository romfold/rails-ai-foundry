# frozen_string_literal: true

require 'rails_ai_foundry/generation/component_generator'

module Foundry
  class CommandGenerator < RailsAIFoundry::Generation::ComponentGenerator
    desc 'Generate a package-owned command in its canonical profile location'

    private

    def component_kind
      'command'
    end
  end
end
