# frozen_string_literal: true

module Search
  module RebuildCutover
    private

    def activate(run, seconds)
      cutover_gate(seconds) do |budget|
        changes = @catalog.projection_changes(after: run[:cursor], through: @catalog.projection_fence)
        unless changes.empty?
          @runs.checkpoint(run, phase: 'catching_up')
          return
        end
        budget.check!
        @runs.checkpoint(run, lease_until: Time.now.utc + 30)
        run[:destination] == 'vectors' ? select_vectors(run, budget) : select_search(run, budget)
      end
    end

    def select_vectors(run, budget)
      @runs.with_owned(run) do
        budget.check!
        @vectors.activate(run[:candidate])
        @runs.checkpoint(run, phase: 'completed')
      end
    end

    def select_search(run, budget)
      prior = @index.selected
      raise 'Expected a single active alias' unless prior.size == 1

      budget.check!
      @runs.checkpoint(run, phase: 'cutting_over', cutover_intent: true, prior_alias: prior.first)
      budget.check!
      @index.guarded_cutover(run[:candidate], previous: prior.first)
      budget.check!
      @runs.checkpoint(run, phase: 'reconciling')
    end

    def reconcile(run, seconds)
      selected = @index.selected
      return retry_alias(run, seconds) if selected == [run[:prior_alias]]
      raise 'Unexpected alias selection; operator repair required' unless selected == [run[:candidate]]

      # The expected prior alias is absent, so a delayed guarded request can no longer select anything.
      cutover_gate(seconds) do |budget|
        changes = @catalog.projection_changes(after: run[:cursor], through: @catalog.projection_fence)
        if changes.empty?
          budget.check!
          @runs.checkpoint(run, phase: 'completed')
        else
          reconcile_batch(run, changes, budget)
        end
      end
    end

    def reconcile_batch(run, changes, budget)
      documents, last_change = change_batch(changes)
      budget.check!
      write(run, documents)
      budget.check!
      @runs.acknowledge(run, documents, cursor: last_change[:id], phase: 'reconciling')
    end

    def retry_alias(run, seconds)
      cutover_gate(seconds) do |budget|
        @runs.checkpoint(run, lease_until: Time.now.utc + 30)
        budget.check!
        @index.guarded_cutover(run[:candidate], previous: run[:prior_alias])
      end
    end

    def cutover_gate(seconds)
      ApplicationTelemetry.measure('rebuild_gate.knowledge') do
        @catalog.with_write_gate do
          budget = CutoverBudget.new(seconds: seconds)
          budget.check!
          yield budget
        end
      end
    end
  end
end
