# frozen_string_literal: true

module Pipeline
  class Cursor < ApplicationRecord
    self.table_name = 'pipeline_cursors'
  end
end
