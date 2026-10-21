# frozen_string_literal: true

require 'active_record'
require 'dry/operation'

module Evidence
  class Entry < ActiveRecord::Base
    self.table_name = 'entries'
  end

  class VanillaWrite
    def call(cents:)
      return false unless cents.is_a?(Integer) && cents.positive?

      Entry.transaction(requires_new: true) { Entry.create!(cents: cents) }
      true
    end
  end

  class NativeWrite < Dry::Operation
    skip_prepending

    def call(cents:)
      result = nil
      Entry.transaction(requires_new: true) do
        result = steps do
          step(cents.is_a?(Integer) && cents.positive? ? Success(cents) : Failure(:invalid))
          Entry.create!(cents: cents)
        end
        raise ActiveRecord::Rollback if result.failure?
      end
      result
    end
  end
end
