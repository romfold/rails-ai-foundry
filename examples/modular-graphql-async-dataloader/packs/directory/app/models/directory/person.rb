# frozen_string_literal: true

module Directory
  class Person < ApplicationRecord
    self.table_name = 'directory_people'
  end
end
