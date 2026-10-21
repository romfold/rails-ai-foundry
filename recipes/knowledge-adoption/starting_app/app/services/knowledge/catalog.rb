# frozen_string_literal: true

module Knowledge
  class Catalog
    def change(principal:, **arguments)
      Access::Identity.authorize!(principal, principal.tenant_id)
      ChangeDocument.new.call(principal: principal, **arguments)
    end

    def list(principal:)
      Access::Identity.authorize!(principal, principal.tenant_id)
      Document.where(tenant_id: principal.tenant_id).where.not(status: 'deleted').order(:created_at)
              .map { |row| row.attributes.symbolize_keys }
    end

    def visible(principal:, ids: nil)
      rows = list(principal: principal).select { |row| row[:status] == 'published' }
      ids ? rows.select { |row| ids.include?(row[:id]) } : rows
    end

    def delivery_status(principal:)
      Access::Identity.authorize!(principal, principal.tenant_id)
      {}
    end
  end
end
