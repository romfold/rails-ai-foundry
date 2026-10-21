# frozen_string_literal: true

module Search
  class CutoverBudget
    class Expired < StandardError; end

    def initialize(seconds: 10)
      @deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + seconds
    end

    def check!
      return unless Process.clock_gettime(Process::CLOCK_MONOTONIC) >= @deadline

      raise Expired,
            'Rebuild write gate budget exhausted'
    end
  end
end
