# frozen_string_literal: true

module Search
  class Service
    class StaleRevision < StandardError; end

    def initialize(catalog:, url:, elasticsearch_url:, index_name:, embeddings: DemoEmbeddings.new)
      @catalog = catalog
      @index = ElasticIndex.new(url: elasticsearch_url, name: index_name)
      @vectors = VectorIndex.new(url: url)
      @embeddings = embeddings
      @runs = RebuildRuns.new(url: url)
      @rebuilder = Rebuilder.new(catalog: @catalog, index: @index, vectors: @vectors, runs: @runs,
                                 embed: lambda { |document, version|
                                   embed(document, version: version, provider: @embeddings)
                                 })
    end

    def setup
      @index.setup
    end

    def project(id, target:)
      document = @catalog.snapshot(id)
      raise ArgumentError, 'Unknown document' unless document

      return @index.upsert(document) if target == 'search'
      raise ArgumentError, 'Unknown destination' unless target == 'vectors'

      embed(document, version: @vectors.active_version, provider: @embeddings)
    end

    def keyword(principal:, query:)
      Access::Identity.authorize!(principal, principal.tenant_id)
      hits = @index.query(tenant_id: principal.tenant_id, query: query)
      visible = @catalog.visible(principal: principal, ids: hits.map(&:first)).index_by { |row| row[:id] }
      hits.filter_map { |id, revision| visible[id] if visible[id] && visible[id][:revision] == revision }
    end

    def retrieve(principal:, query:)
      ApplicationTelemetry.measure('retrieval.knowledge') { retrieve_current(principal: principal, query: query) }
    end

    def retrieve_current(principal:, query:)
      Access::Identity.authorize!(principal, principal.tenant_id)
      ensure_outside_transaction!
      vector = ApplicationTelemetry.measure('embedding_provider.knowledge') { @embeddings.call(query) }
      Retrieval.new(catalog: @catalog, vectors: @vectors).call(principal: principal, vector: vector)
    end

    def start_rebuild(destination:, version: nil)
      @rebuilder.start(destination: destination, version: version)
    end

    def rebuild_status(id = nil)
      statuses = @runs.status(id).map { |run| run.merge(changes_behind: @catalog.projection_lag(after: run[:cursor])) }
      id ? statuses.first : statuses
    end

    def resume_rebuild(id, repair: false, **options)
      @runs.repair(id) if repair
      @rebuilder.step(id, **options)
    end

    def poll_rebuilds
      @runs.pending.each do |run|
        resume_rebuild(run[:id])
      rescue StandardError => e
        ActiveSupport::Notifications.instrument('rebuild_failure.knowledge', error: e.class.name)
      end
    end

    def cancel_rebuild(id)
      @runs.cancel(id)
    end

    def cleanup_rebuild(id, confirm: false)
      run = @runs.get(id)
      raise 'Only terminal inactive candidates can be cleaned' unless %w[cancelled completed].include?(run[:phase])
      raise 'Candidate has unresolved ownership' if unresolved?(run)

      raise 'Candidate is active' if active_candidate?(run)

      delete_candidate(run) if confirm
      { candidate: run[:candidate], dry_run: !confirm }
    end

    def rebuild_search(after_backfill: -> {}, before_validate: -> {}, gate_seconds: 10, run_id: nil)
      run = run_id ? @runs.get(run_id) : start_rebuild(destination: 'search')
      raise ArgumentError, 'Resume destination mismatch' unless run[:destination] == 'search'

      @rebuilder.finish(run[:id], after_backfill: after_backfill, before_validate: before_validate,
                                  gate_seconds: gate_seconds)
    end

    def rebuild_vectors(version:, provider: @embeddings, after_backfill: -> {}, run_id: nil)
      run = run_id ? @runs.get(run_id) : start_rebuild(destination: 'vectors', version: version)
      raise ArgumentError, 'Resume version mismatch' unless run[:destination] == 'vectors' && run[:candidate] == version

      rebuilder = Rebuilder.new(catalog: @catalog, index: @index, vectors: @vectors, runs: @runs,
                                embed: lambda { |document, candidate|
                                  embed(document, version: candidate, provider: provider)
                                })
      rebuilder.finish(run[:id], after_backfill: after_backfill)
    end

    def active_version
      @vectors.active_version
    end

    def disconnect
      @vectors.disconnect
      @runs.disconnect
    end

    private

    def unresolved?(run)
      (run[:cutover_intent] && run[:phase] != 'completed') || (run[:lease_until] && run[:lease_until] > Time.now.utc)
    end

    def active_candidate?(run)
      return @index.selected.include?(run[:candidate]) if run[:destination] == 'search'

      @vectors.active_version == run[:candidate]
    end

    def delete_candidate(run)
      return @index.delete(run[:candidate]) if run[:destination] == 'search'

      @vectors.delete_version(run[:candidate])
    end

    def embed(document, version:, provider:)
      ensure_outside_transaction!
      vector = embedding(document, provider) if document[:status] == 'published'
      @catalog.with_write_gate do
        current = @catalog.snapshot(document[:id])
        raise StaleRevision, 'Document changed while embedding' unless current[:revision] == document[:revision]

        if current[:status] == 'published'
          @vectors.store(current, vector, version: version)
          Digest::SHA256.hexdigest(vector.pack('e*'))
        else
          @vectors.remove(current[:id])
          nil
        end
      end
    end

    def embedding(document, provider)
      ApplicationTelemetry.measure('embedding_provider.knowledge') { provider.call(document[:body]) }
    end

    def ensure_outside_transaction!
      raise ArgumentError, 'Provider work must be outside the writer transaction' if @catalog.transaction_open?
    end
  end
end
