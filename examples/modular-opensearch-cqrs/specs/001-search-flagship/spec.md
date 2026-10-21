# Durable product writes and rebuildable search

Status: implemented and locally verified; see reconciliation.md.

## Behavioral requirements

- A synchronous write commits authoritative product state and outbox intent together, with failed native operation results rolling back their savepoint.
- A dispatcher retries delivery after crashes, bounds poison retries, and supports reviewed replay. Duplicate publication cannot duplicate projection documents.
- A rebuild backfills a new index, catches up under a writer gate, validates complete content, and atomically swaps the read alias. Failure preserves the active alias and old index.
- Search write failures leave business writes committed and recoverable; soft-deletion tombstones prevent stale replay from resurrecting search results.
- Production eager loading uses upstream libraries without Foundry execution code.

## Acceptance

Run `bin/verify` with the disposable services defined in compose.yml. The tests and reconciliation.md identify evidence; prerequisite checks only establish artifact presence.
