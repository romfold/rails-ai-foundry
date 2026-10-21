# frozen_string_literal: true

module Knowledge
  class Catalog
    def self.list(tenant_id:)
      Document.where(tenant_id: tenant_id, published: true).order(:id).map do |document|
        document.attributes.slice('id', 'tenant_id', 'body', 'revision')
      end
    end
  end
end
