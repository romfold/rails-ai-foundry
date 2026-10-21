# frozen_string_literal: true

module Knowledge
  class TenantConstraints
    NAMES = %w[knowledge_tenant_present knowledge_collection_owner].freeze

    def validate
      install
      Document.transaction do
        connection.execute("SET LOCAL lock_timeout = '5s'")
        connection.execute("SET LOCAL statement_timeout = '60s'")
        state = completed_state

        NAMES.each { |name| connection.execute("ALTER TABLE knowledge_documents VALIDATE CONSTRAINT #{name}") }
        state.update!(phase: 'validated')
      end
    end

    def validated?
      rows = connection.select_rows(<<~SQL)
        SELECT conname, convalidated FROM pg_constraint
        WHERE conrelid = 'knowledge_documents'::regclass
          AND conname IN ('knowledge_tenant_present', 'knowledge_collection_owner')
      SQL
      rows.size == NAMES.size && rows.all? { |_, validated| validated }
    end

    private

    def install
      Document.transaction do
        connection.execute("SET LOCAL lock_timeout = '5s'")
        connection.execute("SET LOCAL statement_timeout = '10s'")
        completed_state
        existing = constraint_names
        definitions.each do |name, definition|
          next if existing.include?(name)

          connection.execute("ALTER TABLE knowledge_documents ADD CONSTRAINT #{name} #{definition} NOT VALID")
        end
      end
    end

    def completed_state
      state = TenantMigration.lock.find(1)
      raise TenantRollout::Blocked, 'Backfill has not completed' unless %w[backfilled validated].include?(state.phase)
      raise TenantRollout::Blocked, 'Repair unresolved ownership first' if TenantIssue.exists?

      state
    end

    def constraint_names
      connection.select_values("SELECT conname FROM pg_constraint WHERE conrelid = 'knowledge_documents'::regclass")
    end

    def definitions
      { 'knowledge_tenant_present' => 'CHECK (tenant_id IS NOT NULL)',
        'knowledge_collection_owner' => 'FOREIGN KEY (collection_id, tenant_id) ' \
                                        'REFERENCES knowledge_collections (id, tenant_id)' }
    end

    def connection
      Document.connection
    end
  end
end
