# frozen_string_literal: true

require 'rails_ai_foundry/generation/component_generator'

module Foundry
  class ControllerGenerator < RailsAIFoundry::Generation::ComponentGenerator
    desc 'Generate a native context-owned Rails controller with --context=NAME'

    private

    def component_kind
      'controller'
    end
  end
end
