# frozen_string_literal: true

module Assistance
  class ExecuteResolutionJob < ApplicationJob
    def perform(id)
      ExecuteResolution.call(id)
    end
  end
end
