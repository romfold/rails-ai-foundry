# frozen_string_literal: true

module Catalog
  class RebuildGate < ApplicationRecord
    self.table_name = 'catalog_rebuild_gates'

    def self.synchronize(&)
      create_or_find_by!(name: 'search').with_lock(&)
    end
  end
end
