## Purpose

Replay projection history in bounded batches while preserving event order, visibility, filtering, and transaction rollback.

## ADDED Requirements

### Requirement: Rebuild reads bounded relevant history
Projection rebuild SHALL enumerate history in batches defaulting to 1,000 records, apply event-type filtering in the store query before contract decoding, and preserve event order. Existing history and stream-read methods SHALL continue returning arrays.

#### Scenario: Multiple batches and unrelated contracts
- **WHEN** a projection rebuild spans more than one batch and the store includes unrelated unsupported event types
- **THEN** all relevant events are processed in order and unrelated contracts are not decoded

#### Scenario: Empty history or filter
- **WHEN** no relevant records exist or the requested type filter is empty
- **THEN** enumeration yields no events

### Requirement: Rebuild visibility is fixed at enumeration start
Enumeration SHALL exclude events not visible when iteration begins, including later appends and PostgreSQL transactions that commit later with earlier sequence identifiers. Rebuild SHALL preserve its projection lock and atomic rollback on unsupported contracts or handler failures.

#### Scenario: Appends during iteration
- **WHEN** events are appended after the initial history boundary is captured
- **THEN** they are excluded from that enumeration and included in a subsequent one

#### Scenario: Late commit below the boundary
- **WHEN** an earlier PostgreSQL event insertion is uncommitted at enumeration start and commits between batches
- **THEN** the event remains excluded from that enumeration

#### Scenario: Failure after a complete batch
- **WHEN** a later event cannot be decoded or its handler fails
- **THEN** prior rebuild read-model and processing-receipt changes roll back without rewriting history

### Requirement: Aggregate replay remains compatible
Aggregate load SHALL retain full-stream replay. Save SHALL retain its reread so the returned aggregate has its current version and no pending events.

#### Scenario: Saved aggregate
- **WHEN** pending events are saved successfully
- **THEN** the returned aggregate reflects stored history and has an empty pending-event list
