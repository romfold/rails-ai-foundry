# frozen_string_literal: true

require 'rails_ai_foundry/generation/component_generator'

module Foundry
  class JobGenerator < RailsAIFoundry::Generation::ComponentGenerator
    desc 'Generate a native context-owned Rails job with --context=NAME'

    private

    def component_kind
      'job'
    end
  end
end
