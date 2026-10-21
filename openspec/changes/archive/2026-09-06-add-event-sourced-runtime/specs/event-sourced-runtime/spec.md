## Purpose

Make authoritative event streams usable for aggregate state and reproducible, package-owned read models with safe concurrency and replay behavior.

## ADDED Requirements

### Requirement: Authoritative aggregate streams
Event-sourced packages SHALL reconstruct pure Ruby aggregates from ordered versioned events and append pending events with the loaded stream version. Conflicting writes SHALL fail with a reload-and-retry diagnostic without overwriting committed events.

#### Scenario: Replay and conflict
- **WHEN** two aggregate instances load the same version and both attempt to append changes
- **THEN** the first append succeeds, the stale append fails, and reloading reconstructs exactly the committed state

### Requirement: Persistent projection idempotency
Foundry SHALL generate projection processing migrations and read models in canonical locations. Explicit projection registration SHALL validate package ownership, public dependencies, and exclusive read-model ownership. Processing an event and recording its identity SHALL commit or roll back together; duplicate handling SHALL be harmless.

#### Scenario: Duplicate and failed processing
- **WHEN** the same event is delivered twice or a projection handler fails
- **THEN** duplicates produce one committed effect and failures commit neither the processing receipt nor read-model writes

### Requirement: Scoped projection rebuild
A package-scoped rebuild task SHALL reset only the selected registered projection's owned read models and processing receipts and replay its event contracts in stored order. It SHALL preserve event streams and unrelated tables, serialize against normal processing, and never republish events or invoke ordinary subscriptions. Unknown projections SHALL fail before destructive writes.

#### Scenario: Rebuild from authoritative history
- **WHEN** a projection is rebuilt after its read model is lost
- **THEN** its state is reproduced without truncating event streams or repeating ordinary subscriber effects

#### Scenario: Failed replay
- **WHEN** an unsupported event version or handler failure interrupts rebuilding
- **THEN** the transaction restores the previous read models and receipts and reports the failure
