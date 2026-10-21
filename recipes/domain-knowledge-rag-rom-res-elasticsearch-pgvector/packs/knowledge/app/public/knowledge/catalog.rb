# frozen_string_literal: true

module Knowledge
  class Catalog
    def initialize(url:)
      @database = Database.new(url)
    end

    def change(principal:, **arguments)
      Access::Identity.authorize!(principal, principal.tenant_id)
      Commands::ChangeDocument.new(database: @database, queue: queue).call(principal: principal, **arguments)
    end

    def list(principal:, after: nil, limit: Rails.configuration.x.knowledge_limits.fetch(:document_page))
      Access::Identity.authorize!(principal, principal.tenant_id)
      validate_limit!(limit, limits.fetch(:document_maximum))
      validate_cursor!(after) if after

      rows = @database.documents.where(tenant_id: principal.tenant_id).exclude(status: 'deleted')
      rows = rows.where { id > after } if after
      rows.order(:id).limit(limit).all
    end

    def visible(principal:, ids: nil)
      Access::Identity.authorize!(principal, principal.tenant_id)
      rows = @database.documents.where(tenant_id: principal.tenant_id, status: 'published')
      rows = rows.where(id: ids) if ids
      raise ArgumentError, 'Too many document identifiers' if ids && ids.size > 100

      rows.order(:id).limit(100).all
    end

    def projection_fence
      with_write_gate { @database.connection[:knowledge_projection_changes].max(:id) || 0 }
    end

    def projection_lag(after:)
      @database.connection[:knowledge_projection_changes].where { id > after }.count
    end

    def projection_start
      with_write_gate do
        { fence: projection_fence, upper_id: @database.documents.order(Sequel.desc(:id)).get(:id) }
      end
    end

    def snapshot_page(upper_id:, after: nil, limit: Rails.configuration.x.knowledge_limits.fetch(:rebuild_page))
      return [] unless upper_id
      raise ArgumentError, 'Invalid batch size' unless (1..250).cover?(limit)

      rows = @database.documents.where { id <= upper_id }
      rows = rows.where { id > after } if after
      ids = bounded_ids(rows.order(:id).limit(limit))
      documents = @database.documents.where(id: ids).order(:id).all
      report_snapshot(documents)
    end

    def projection_changes(after:, through:, limit: Rails.configuration.x.knowledge_limits.fetch(:rebuild_page))
      raise ArgumentError, 'Invalid batch size' unless (1..250).cover?(limit)

      # An acknowledged cursor must still exist: journal pruning is not supported.
      journal = @database.connection[:knowledge_projection_changes]
      verify_cursor!(journal, after)

      changes = journal.where { (id > after) & (id <= through) }.order(:id).limit(limit).all
      verify_chain!(changes, after: after, through: through, limit: limit)
      changes
    end

    def snapshot(id)
      @database.documents.where(id: id).first
    end

    def with_write_gate(&)
      @database.gate(&)
    end

    def transaction_open?
      @database.connection.in_transaction?
    end

    def queue
      DeliveryQueue.new(connection: @database.connection)
    end

    def delivery_status(principal:, ids:)
      Access::Identity.authorize!(principal, principal.tenant_id)
      raise ArgumentError, 'Too many document identifiers' if ids.size > 100

      owned = @database.documents.where(tenant_id: principal.tenant_id, id: ids).select_map(:id)
      queue.document_status(owned)
    end

    def disconnect
      @database.disconnect
    end

    private

    def limits
      Rails.configuration.x.knowledge_limits
    end

    def validate_limit!(limit, maximum)
      raise ArgumentError, 'Invalid page limit' unless (1..maximum).cover?(limit)
    end

    def validate_cursor!(cursor)
      return if /\A[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}\z/i.match?(cursor)

      raise ArgumentError,
            'Invalid document cursor'
    end

    def report_snapshot(documents)
      ActiveSupport::Notifications.instrument('snapshot_page.knowledge', rows: documents.size,
                                                                         bytes: JSON.generate(documents).bytesize)
      documents
    end

    def bounded_ids(rows)
      sizes = rows.select(:id, Sequel.lit('octet_length(body) + octet_length(title)').as(:bytes)).all
      bytes = 0
      sizes.take_while do |row|
        maximum = limits.fetch(:bulk_bytes)
        raise ArgumentError, 'Oversized projection record' if row[:bytes] + 512 > maximum

        bytes += row[:bytes] + 512
        bytes <= maximum
      end.pluck(:id)
    end

    def verify_cursor!(journal, cursor)
      raise 'Missing projection history' if cursor.positive? && !journal.where(id: cursor).first
    end

    def verify_chain!(changes, after:, through:, limit:)
      previous = after
      changes.each do |change|
        raise 'Missing projection history' unless change[:previous_id] == previous

        previous = change[:id]
      end
      raise 'Missing projection history' if changes.size < limit && previous != through
    end
  end
end
