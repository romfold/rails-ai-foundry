# frozen_string_literal: true

module Search
  # Application persistence, deliberately not a Foundry execution abstraction.
  class RebuildRuns
    class OwnershipLost < StandardError; end

    def initialize(url:)
      @url = url
    end

    def start(destination:, candidate:, fence:, upper_id:)
      raise ArgumentError, 'Unknown destination' unless %w[search vectors].include?(destination)

      now = Time.now.utc
      id = SecureRandom.uuid
      rows.insert(id: id, destination: destination, candidate: candidate, initial_fence: fence, cursor: fence,
                  upper_id: upper_id, created_at: now, updated_at: now, options: current_options)
      get(id)
    end

    def get(id)
      rows.where(id: id).first || raise(ArgumentError, 'Unknown rebuild')
    end

    def status(id = nil)
      selected = id ? [get(id)] : rows.order(Sequel.desc(:created_at)).limit(20).all
      selected.map { |run| run.except(:lease_token).merge(documents_processed: expected_count(run)) }
    end

    def pending
      rows.exclude(phase: %w[completed cancelled]).where(poisoned: false)
          .where(Sequel.|({ retry_at: nil }, Sequel[:retry_at] <= Time.now.utc)).order(:created_at).limit(2).all
    end

    def claim(id)
      database.transaction do
        run = lock(id)
        return if %w[completed cancelled].include?(run[:phase])
        return if leased?(run)

        raise 'Rebuild requires explicit repair' if run[:poisoned]
        raise ArgumentError, 'Resume options mismatch' unless run[:options] == current_options

        lease(run)
      end
    end

    def checkpoint(run, **attributes)
      attributes = attributes.merge(updated_at: Time.now.utc)
      raise OwnershipLost, 'Expired rebuild ownership' unless owned(run).update(attributes) == 1

      run.merge!(attributes)
    end

    def acknowledge(run, documents, **attributes)
      database.transaction do
        raise OwnershipLost, 'Expired rebuild ownership' unless owned(run).for_update.first

        documents.each { |document| save_entry(run, document) }
        checkpoint(run, **attributes)
      end
    end

    def with_owned(run)
      database.transaction do
        raise OwnershipLost, 'Expired rebuild ownership' unless owned(run).for_update.first

        yield
      end
    end

    def release(run)
      owned(run).update(lease_token: nil, lease_until: nil)
    end

    def fail(run, error)
      count = run[:failure_count] + 1
      checkpoint(run, error_code: error.class.name, failure_count: count, poisoned: count >= 5,
                      retry_at: Time.now.utc + [2**count, 60].min)
    rescue OwnershipLost
      # A replacement owns the error/retry state now.
      nil
    end

    def repair(id)
      database.transaction do
        run = lock(id)
        raise 'Worker still leased' if leased?(run)

        rows.where(id: id).update(poisoned: false, failure_count: 0, retry_at: nil, error_code: nil)
      end
    end

    def cancel(id)
      database.transaction do
        run = lock(id)
        raise 'Reconcile cutover before cancelling' if run[:cutover_intent]
        raise 'Completed rebuild cannot be cancelled' if run[:phase] == 'completed'

        rows.where(id: id).update(phase: 'cancelled')
      end
    end

    def manifest(run, after: nil, limit: Rails.configuration.x.knowledge_limits.fetch(:rebuild_page))
      query = entries.where(run_id: run[:id])
      query = query.where { document_id > after } if after
      ids = manifest_ids(query.order(:document_id).limit(limit))
      query.where(document_id: ids).order(:document_id).all.map do |row|
        JSON.parse(row[:payload], symbolize_names: true)
      end
    end

    def expected_count(run, published: false)
      query = entries.where(run_id: run[:id])
      query = query.where(Sequel.lit("payload::jsonb ->> 'status' = 'published'")) if published
      query.count
    end

    def disconnect
      @rom&.disconnect
    end

    private

    def manifest_ids(query)
      sizes = query.select(:document_id, Sequel.lit('octet_length(payload)').as(:bytes)).all
      bytes = 0
      maximum = Rails.configuration.x.knowledge_limits.fetch(:bulk_bytes)
      sizes.take_while do |row|
        raise 'Oversized manifest record' if row[:bytes] > maximum

        bytes += row[:bytes]
        bytes <= maximum
      end.pluck(:document_id)
    end

    def lock(id)
      rows.where(id: id).for_update.first || raise(ArgumentError, 'Unknown rebuild')
    end

    def save_entry(run, document)
      payload = document.slice(:id, :tenant_id, :revision, :status, :title, :body, :embedding_digest)
      data = { run_id: run[:id], document_id: document.fetch(:id), revision: document.fetch(:revision),
               payload: JSON.generate(payload) }
      entries.insert_conflict(target: %i[run_id document_id], update: data).insert(data)
    end

    def current_options
      JSON.generate(Rails.configuration.x.knowledge_limits.slice(:rebuild_page, :bulk_bytes))
    end

    def lease(run)
      run.merge!(lease_token: SecureRandom.uuid, lease_until: Time.now.utc + 30, attempts: run[:attempts] + 1)
      rows.where(id: run[:id]).update(run.except(:id))
      run
    end

    def leased?(run)
      run[:lease_until] && run[:lease_until] > Time.now.utc
    end

    def database
      @rom ||= ROM.container(:sql, @url, after_connect: lambda { |connection|
        connection.exec("SET statement_timeout = '2s'")
        connection.exec("SET lock_timeout = '2s'")
      })
      @rom.gateways[:default].connection.tap { |connection| connection.timezone = :utc }
    end

    def rows
      database[:search_rebuild_runs]
    end

    def entries
      database[:search_rebuild_entries]
    end

    def owned(run)
      rows.where(id: run[:id], lease_token: run[:lease_token]).exclude(phase: 'cancelled').where do
        lease_until > Time.now.utc
      end
    end
  end
end
