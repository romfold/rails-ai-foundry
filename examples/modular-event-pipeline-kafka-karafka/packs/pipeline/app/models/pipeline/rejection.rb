# frozen_string_literal: true

module Pipeline
  class Rejection < ApplicationRecord
    self.table_name = 'pipeline_rejections'
  end
end
