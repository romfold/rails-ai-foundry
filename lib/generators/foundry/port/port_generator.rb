# frozen_string_literal: true

require 'rails_ai_foundry/generation/component_generator'

module Foundry
  class PortGenerator < RailsAIFoundry::Generation::ComponentGenerator
    desc 'Generate a package-owned port in its canonical profile location'

    private

    def component_kind
      'port'
    end
  end
end
