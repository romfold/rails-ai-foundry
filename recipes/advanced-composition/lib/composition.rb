# frozen_string_literal: true

require 'dry/system'
require 'dry/system/container'
require 'trailblazer/operation'
require_relative 'place_order'

module Billing
  module Composition
    def self.build(rom:, authorize:)
      container = Class.new(Dry::System::Container)
      container.register('place_order') { PlaceOrder.new(rom: rom, authorize: authorize) }
      container.finalize!
      container
    end
  end

  # Alternative workflow: retain Trailblazer's own result, with no Dry/Foundry wrapper.
  class Quote < Trailblazer::Operation
    step :authorize
    step :calculate?

    def authorize(_context, policy:, **)
      policy.call
    end

    def calculate?(context, cents:, **)
      return false unless cents.is_a?(Integer) && cents.positive?

      context[:total] = cents + 100
      true
    end
  end
end
