# frozen_string_literal: true

module Knowledge
  class TenantMigration < ApplicationRecord
    self.table_name = 'knowledge_tenant_migrations'
  end
end
