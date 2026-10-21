## Context

Modular events already provide explicit contracts, primary-database transactions, and reloadable synchronous subscriptions. Full-domain generators and layer checks are available. See proposal.md for the missing event-sourcing behavior.

## Goals / Non-Goals

Goals: ordered aggregate reconstruction, optimistic appends, persisted idempotency, and scoped local rebuilds.
Non-goals: distributed workers, snapshots, outbox delivery, automatic conversion of existing state, or arbitrary IO safety guarantees for user-written handlers.

## Decisions

A pure Ruby aggregate applies committed history and records pending events. Persistence returns a freshly reconstructed aggregate and leaves the input instance unchanged; callers reload after rollback or concurrency errors. The package bus owns stream names and uses Rails Event Store expected versions.

Projection generators create a dedicated processing table per projection. A persisted sentinel row serializes live processing and rebuild through the primary database transaction; uniqueness additionally protects event identity. Register projection event contracts, an injected handler, and exclusively owned read-model classes in composition. Reject ownership conflicts before subscription.

Rebuild reads stored global history filtered to registered contracts, invokes only the selected projection, and never publishes events. Delete only registered read-model rows and that projection's processing receipts; retain the sentinel and all event streams. The complete reset/replay is transactional. SQLite's single writer and row-locking databases provide local serialization; concurrent lock failures fail safely and require retry.

## Risks / Trade-offs

Long rebuilds hold a transaction and require a maintenance window for large datasets. Arbitrary injected handler IO is not sandboxed: projection handlers must contain only local read-model changes, with static checks and behavior tests reinforcing the contract. A failed outer command may invalidate any previously returned in-memory aggregate; reload before retrying.

## Migration Plan

Apply generated projection migrations separately. Existing event setup migrations remain unchanged. Event-sourcing adoption requires a developer-owned migration and cutover plan; this change never converts stored business state.
