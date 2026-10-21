## Purpose

Ensure projection delivery and event publication retain database-backed consistency under PostgreSQL concurrency.

## ADDED Requirements

### Requirement: Projection processing requires a compatible schema
Processing and rebuild SHALL require a processing table with a non-null event_id and an unconditional unique index on exactly that column. Missing or incompatible schemas SHALL fail with an actionable ContractError before handler effects.

#### Scenario: Missing or weakened processing schema
- **WHEN** the table or event_id is missing, event_id is nullable, or uniqueness is partial, composite, or absent
- **THEN** processing fails with the table name and required migration constraints without applying the handler

#### Scenario: Generated schema
- **WHEN** the generated processing migration has run
- **THEN** processing is accepted on SQLite and PostgreSQL 17

### Requirement: Concurrent processing retains transactional ownership
Independent PostgreSQL connections SHALL serialize projection effects, deduplicate delivery, and reject stale aggregate publication without adding automatic retries. Rebuild and publication SHALL preserve synchronous atomic effects and event history.

#### Scenario: First delivery races
- **WHEN** two independent connections deliver the same event while the lock row is initially absent
- **THEN** one lock row and one processing receipt remain and the read model changes once

#### Scenario: Rebuild overlaps publication
- **WHEN** a barrier holds a rebuild while another connection publishes
- **THEN** both complete consistently and the read model accounts for each event once

#### Scenario: Stale aggregate publication
- **WHEN** independently loaded aggregates compete for the same expected stream version
- **THEN** one succeeds and the stale writer receives a conflict without appended losing events

### Requirement: Database verification is explicitly disposable
PostgreSQL tests SHALL require an explicit disposable test database configuration and isolate their own schema. They SHALL verify PostgreSQL major version 17 and preserve unrelated schemas.

#### Scenario: Missing explicit database
- **WHEN** the PostgreSQL lane runs without its required test URL
- **THEN** it fails with setup guidance rather than selecting an application database
