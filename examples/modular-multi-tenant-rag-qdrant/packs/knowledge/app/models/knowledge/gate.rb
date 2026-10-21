# frozen_string_literal: true

module Knowledge
  class Gate < ApplicationRecord
    self.table_name = 'knowledge_gates'

    def self.synchronize(&)
      create_or_find_by!(name: 'projection').with_lock(&)
    end
  end
end
