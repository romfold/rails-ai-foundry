# frozen_string_literal: true

module Knowledge
  class Document < ActiveRecord::Base
    self.table_name = 'documents'
  end
end
