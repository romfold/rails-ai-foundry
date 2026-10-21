# frozen_string_literal: true

require 'rails/railtie'

module RailsAIFoundry
  class Railtie < Rails::Railtie
    rake_tasks do
      load File.expand_path('../tasks/foundry_native.rake', __dir__)
    end
  end
end
