# frozen_string_literal: true

module Ledger
  class Account
    attr_reader :balance, :version

    def initialize(events)
      @balance = 0
      @version = -1
      events.each do |event|
        @balance += event.data.fetch(:cents)
        @version += 1
      end
    end
  end
end
