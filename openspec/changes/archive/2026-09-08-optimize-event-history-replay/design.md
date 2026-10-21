## Context

Store#history currently loads the full array; projection rebuild wraps that read in its existing lock and transaction. RubyEventStore 3.1 exposes of_type, in_batches, each_batch, last and an exclusive to boundary.

## Goals / Non-Goals

**Goals:** Bounded history memory and exact start visibility with unchanged consumer array interfaces.

**Non-Goals:** Aggregate snapshots, event rewrites, save-reread removal, timing claims, changed transaction boundaries.

## Decisions

- Use the public event-store query API for SQLite type filtering and batching. At iteration start capture the last visible envelope, enumerate strictly before it, then include it once because to is exclusive. Empty filters yield nothing.
- PostgreSQL uses a NO SCROLL transaction-scoped cursor over filtered, ordered event IDs. Each FETCH returns at most the batch size; resolve those IDs through the public event-store query before decoding. The cursor's statement visibility excludes late commits, including subtransactions, without materializing all IDs in Ruby. Avoid private RubyEventStore models; use a Foundry-owned query model for the known event table.
- Close cursors on success and error, preserving an original failure if PostgreSQL has already aborted the transaction. No persistent cursor, exported snapshot, or aggregate snapshot is introduced.
- Rebuild begins enumeration while holding its existing projection lock. Consumer history returns to_a; stream reads and AggregateRepository#save remain unchanged.

## Risks / Trade-offs

PostgreSQL cursors retain a database read view for the duration of replay and add bounded ID fetches. Tests must include late commits below the high-water mark. Full-stream aggregate replay remains unbounded and is documented.
