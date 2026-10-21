# frozen_string_literal: true

module Search
  class Rebuilder
    include RebuildCutover

    def initialize(catalog:, index:, vectors:, runs:, embed:)
      @catalog = catalog
      @index = index
      @vectors = vectors
      @runs = runs
      @embed = embed
    end

    def start(destination:, version: nil)
      raise ArgumentError, 'Unknown destination' unless %w[search vectors].include?(destination)
      if destination == 'vectors' && (version.to_s.empty? || version == @vectors.active_version)
        raise ArgumentError, 'Use a fresh embedding version'
      end

      candidate = destination == 'search' ? "#{@index.name}_#{SecureRandom.hex(6)}" : version
      @catalog.with_write_gate do
        start = @catalog.projection_start
        @runs.start(destination: destination, candidate: candidate, fence: start[:fence], upper_id: start[:upper_id])
      end
    end

    # Each call performs one recoverable unit. Queue scheduling is not the source of truth.
    def step(id, after_write: -> {}, gate_seconds: 10)
      run = @runs.claim(id)
      return @runs.get(id) unless run

      ApplicationTelemetry.measure('rebuild_unit.knowledge') do
        perform(run, after_write: after_write, gate_seconds: gate_seconds)
      end
      @runs.checkpoint(run, failure_count: 0, error_code: nil, retry_at: nil)
      @runs.get(id)
    rescue StandardError => e
      @runs.fail(run, e) if run
      raise
    ensure
      @runs.release(run) if run
    end

    def finish(id, after_backfill: -> {}, before_validate: -> {}, gate_seconds: 10)
      hooks = { 'catching_up' => after_backfill, 'validating' => before_validate }
      10_000.times do
        run = @runs.get(id)
        return run[:candidate] if run[:phase] == 'completed'

        ensure_resumable!(run)
        hooks.delete(run[:phase])&.call
        step(id, gate_seconds: gate_seconds)
      end
      raise 'Rebuild work budget exhausted; resume the same run'
    end

    private

    def ensure_resumable!(run)
      raise 'Rebuild cancelled' if run[:phase] == 'cancelled'
      return unless run[:lease_until] && run[:lease_until] > Time.now.utc

      raise RebuildRuns::OwnershipLost, 'A worker is active; inspect status before resuming'
    end

    def perform(run, after_write:, gate_seconds:)
      ensure_candidate!(run) unless run[:phase] == 'queued'
      case run[:phase]
      when 'queued' then initialize_candidate(run)
      when 'backfilling' then backfill(run, after_write)
      when 'catching_up' then catch_up(run, after_write)
      when 'validating' then validate(run)
      else perform_cutover(run, gate_seconds)
      end
    end

    def perform_cutover(run, seconds)
      case run[:phase]
      when 'ready' then activate(run, seconds)
      when 'cutting_over', 'reconciling' then reconcile(run, seconds)
      else raise 'Unsupported rebuild phase'
      end
    end

    def initialize_candidate(run)
      @index.create(run[:candidate]) if run[:destination] == 'search' && !@index.exists?(run[:candidate])
      @runs.checkpoint(run, phase: 'backfilling')
    end

    def ensure_candidate!(run)
      return unless run[:destination] == 'search'
      raise 'Missing rebuild candidate' unless @index.exists?(run[:candidate])
    end

    def backfill(run, after_write)
      documents = @catalog.snapshot_page(after: run[:page_key], upper_id: run[:upper_id])
      if documents.empty?
        @runs.checkpoint(run, phase: 'catching_up')
      else
        documents = bounded(documents)
        write(run, documents)
        after_write.call
        @runs.acknowledge(run, documents, page_key: documents.last[:id])
      end
    end

    def catch_up(run, after_write)
      fence = @catalog.projection_fence
      changes = @catalog.projection_changes(after: run[:cursor], through: fence)
      if changes.empty?
        validate_count!(run) if run[:validated]
        @runs.checkpoint(run, phase: run[:validated] ? 'ready' : 'validating', validation_key: nil)
      else
        documents, last_change = change_batch(changes)
        write(run, documents)
        validate_page!(run, documents) if run[:validated]
        after_write.call
        @runs.acknowledge(run, documents, cursor: last_change[:id])
      end
    end

    def change_batch(changes)
      documents = []
      consumed = []
      changes.each do |change|
        document = @catalog.snapshot(change[:document_id]) || raise('Missing source tombstone')
        break unless bounded(documents + [document]).size == documents.size + 1

        documents << document
        consumed << change
      end
      [documents, consumed.last]
    end

    def bounded(documents)
      bytes = 0
      documents.take_while do |document|
        size = JSON.generate(document).bytesize + 512
        if size > Rails.configuration.x.knowledge_limits.fetch(:bulk_bytes)
          raise ArgumentError,
                'Oversized projection record'
        end

        bytes += size
        bytes <= Rails.configuration.x.knowledge_limits.fetch(:bulk_bytes)
      end
    end

    def write(run, documents)
      @runs.checkpoint(run, lease_until: Time.now.utc + 30)
      if run[:destination] == 'search'
        @index.bulk(documents, index: run[:candidate])
      else
        documents.each { |document| document[:embedding_digest] = @embed.call(document, run[:candidate]) }
      end
    end

    def validate(run)
      if @catalog.projection_fence != run[:cursor]
        @runs.checkpoint(run, phase: 'catching_up', validation_key: nil)
        return
      end

      documents = @runs.manifest(run, after: run[:validation_key])
      if documents.empty?
        validate_count!(run)
        @runs.checkpoint(run, phase: 'ready', validated: true)
      else
        validate_page!(run, documents)
        @runs.checkpoint(run, validation_key: documents.last[:id])
      end
    end

    def validate_page!(run, documents)
      if run[:destination] == 'search'
        @index.validate_page!(documents, index: run[:candidate])
      else
        @vectors.validate_page!(documents, version: run[:candidate])
      end
    end

    def validate_count!(run)
      vector = run[:destination] == 'vectors'
      actual = vector ? @vectors.count(run[:candidate]) : @index.count(run[:candidate])
      raise 'Projection membership mismatch' unless actual == @runs.expected_count(run, published: vector)
    end
  end
end
