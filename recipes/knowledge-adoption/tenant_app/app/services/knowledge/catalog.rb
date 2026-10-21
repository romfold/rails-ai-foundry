# frozen_string_literal: true

module Knowledge
  class Catalog
    def self.with_tenant_migration
      new(migration: TenantRollout.new)
    end

    def initialize(migration: nil)
      @migration = migration
    end

    def list(tenant:)
      visible(tenant).order(:id).limit(100).map { |row| serialize(row) }
    end

    def create(tenant:, collection_id:, title:, body:)
      mutate do
        collection = Collection.find_by!(id: collection_id, tenant_id: tenant)
        attributes = { collection: collection, title: title, body: body }
        attributes[:tenant_id] = collection.tenant_id if @migration
        serialize(Document.create!(attributes))
      end
    end

    def update(tenant:, id:, revision:, title:, body:)
      mutate do
        row = visible(tenant).lock('FOR UPDATE OF knowledge_documents').find(id)
        raise ActiveRecord::StaleObjectError unless row.revision == revision

        attributes = { title: title, body: body, revision: revision + 1 }
        attributes[:tenant_id] = row.collection.tenant_id if @migration
        row.update!(attributes)
        serialize(row)
      end
    end

    def delete(tenant:, id:)
      mutate { visible(tenant).lock('FOR UPDATE OF knowledge_documents').find(id).destroy! }
    end

    private

    def visible(tenant)
      return Document.where(tenant_id: tenant) if @migration&.active?

      Document.joins(:collection).where(knowledge_collections: { tenant_id: tenant })
    end

    def mutate(&)
      return @migration.write(&) if @migration

      Document.transaction(&)
    end

    def serialize(row)
      row.attributes.except('tenant_id').merge('tenant_id' => row.collection.tenant_id)
    end
  end
end
