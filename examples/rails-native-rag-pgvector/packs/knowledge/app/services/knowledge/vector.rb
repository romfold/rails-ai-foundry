# frozen_string_literal: true

module Knowledge
  module Vector
    def self.encode(values)
      numbers = Array(values).map { |value| Float(value) }
      unless numbers.length == 1536 && numbers.all?(&:finite?) && numbers.any?(&:nonzero?)
        raise ArgumentError, 'Expected 1536 finite values and a nonzero vector'
      end

      "[#{numbers.join(',')}]"
    end
  end
end
