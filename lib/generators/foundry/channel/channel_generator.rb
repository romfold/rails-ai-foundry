# frozen_string_literal: true

require 'rails_ai_foundry/generation/component_generator'

module Foundry
  class ChannelGenerator < RailsAIFoundry::Generation::ComponentGenerator
    desc 'Generate a native context-owned Rails channel with --context=NAME'

    private

    def component_kind
      'channel'
    end
  end
end
