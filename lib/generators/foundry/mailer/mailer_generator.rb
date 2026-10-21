# frozen_string_literal: true

require 'rails_ai_foundry/generation/component_generator'

module Foundry
  class MailerGenerator < RailsAIFoundry::Generation::ComponentGenerator
    desc 'Generate a native context-owned Rails mailer with --context=NAME'

    private

    def component_kind
      'mailer'
    end
  end
end
