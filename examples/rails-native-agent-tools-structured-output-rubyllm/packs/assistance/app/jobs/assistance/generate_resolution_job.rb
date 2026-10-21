# frozen_string_literal: true

module Assistance
  class GenerateResolutionJob < ApplicationJob
    def perform(id)
      GenerateResolution.call(id)
    end
  end
end
