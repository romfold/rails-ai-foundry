# frozen_string_literal: true

module Knowledge
  class TenantIssue < ApplicationRecord
    self.table_name = 'knowledge_tenant_issues'
    self.primary_key = 'document_id'
  end
end
