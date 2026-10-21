# frozen_string_literal: true

module Knowledge
  class TenantBackfill
    BATCH_SIZE = 250

    def start(old_writers_stopped:)
      raise TenantRollout::Blocked, 'Confirm that all old writers have stopped' unless old_writers_stopped

      TenantMigration.create_or_find_by!(id: 1)
      transaction do |state|
        if state.phase == 'expanded'
          state.update!(phase: 'backfilling', scan_bound: Document.maximum(:id) || 0,
                        writers_confirmed_at: Time.current)
        end
      end
    end

    def batch
      transaction do |state|
        raise TenantRollout::Blocked, 'Start the compatible-writer rollout first' if state.phase == 'expanded'
        next 0 unless state.phase == 'backfilling'

        rows = next_rows(state)
        rows.each { |row| fill(row) }
        checkpoint(state, rows)
        before_commit
        rows.size
      end
    end

    def repair(document_id:, collection_id:)
      transaction do |state|
        raise TenantRollout::Blocked, 'Cannot repair validated ownership' if state.phase == 'validated'

        row = Document.lock.find(document_id)
        raise TenantRollout::Blocked, 'Collection identity changed' unless row.collection_id == collection_id

        fill(row)
        if TenantIssue.exists?(document_id: row.id)
          raise TenantRollout::Blocked,
                'Trusted collection still has no owner'
        end
      end
    end

    private

    def next_rows(state)
      Document.where('id > ? AND id <= ?', state.cursor, state.scan_bound).order(:id).limit(BATCH_SIZE).lock.to_a
    end

    def checkpoint(state, rows)
      state.update!(cursor: rows.last&.id || state.scan_bound)
      state.update!(phase: 'backfilled') if state.cursor >= state.scan_bound
    end

    def transaction
      Document.transaction do
        Document.connection.execute("SET LOCAL lock_timeout = '5s'")
        Document.connection.execute("SET LOCAL statement_timeout = '10s'")
        yield TenantMigration.lock.find(1)
      end
    end

    def fill(row)
      owner = Collection.lock('FOR SHARE').find(row.collection_id).tenant_id
      unless owner
        TenantIssue.upsert({ document_id: row.id, reason: 'unmapped_collection' }, unique_by: :document_id)
        return
      end
      raise TenantRollout::Blocked, 'Conflicting document ownership' if row.tenant_id && row.tenant_id != owner

      row.update_columns(tenant_id: owner)
      TenantIssue.where(document_id: row.id).delete_all
    end

    # A subclass in process acceptance provides an explicit crash synchronization point.
    def before_commit; end
  end
end
