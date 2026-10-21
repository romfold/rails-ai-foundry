# frozen_string_literal: true

module Directory
  class Current < ActiveSupport::CurrentAttributes
    attribute :tenant
  end
end
