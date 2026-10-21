# frozen_string_literal: true

module Assistance
  class ResolutionAudit < ApplicationRecord
    self.table_name = 'resolution_audits'
    def readonly?
      persisted?
    end
  end
end
