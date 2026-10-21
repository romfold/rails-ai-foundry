## Purpose

Provide an executable local inventory consumer demonstrating event-sourced domain rules, persistence, evolution, and projections.

## ADDED Requirements

### Requirement: Inventory operations preserve domain invariants
The example SHALL support restocking, reserving, and releasing inventory through an event-sourced aggregate. Quantities SHALL be positive integers; reservations SHALL not exceed availability and releases SHALL not exceed reserved quantity. Rejected operations SHALL append no events.

#### Scenario: Successful inventory flow
- **WHEN** an item is restocked by 10, reserved by 4 and released by 2
- **THEN** replay and the projection report 10 on hand, 2 reserved and 8 available

#### Scenario: Invalid operations
- **WHEN** a quantity is nonpositive or noninteger, a reservation exceeds availability, or a release exceeds reservations
- **THEN** the operation fails explicitly and the stream and read model remain unchanged

### Requirement: Example commands are preserving and executable
The host SHALL provide bin/setup, bin/demo, and bin/verify using its own locked bundle and PostgreSQL 17. Setup SHALL preserve existing data. Each demo SHALL use a fresh stream identifier and print deterministic state assertions.

#### Scenario: Repeated setup and demo
- **WHEN** setup and demo are repeated
- **THEN** existing event history remains intact and each demo succeeds on a fresh stream

### Requirement: Example demonstrates event evolution and recovery
The example SHALL include a committed older payload fixture, read-time upcasting, projection rebuild, and optimistic-concurrency verification without rewriting historical events.

#### Scenario: Historical fixture and rebuild
- **WHEN** the committed older fixture is appended to a fresh fixture stream and replayed
- **THEN** the current immutable contract produces the expected inventory state and rebuild reproduces the read model while stored bytes remain unchanged

#### Scenario: Stale reservation
- **WHEN** two loaded aggregates compete at the same stream version
- **THEN** one succeeds and the stale write fails without appending its events

### Requirement: Reference application remains a local independent consumer
The host SHALL retain an independent locked application bundle, a v2 event_sourced Inventory package generated through public commands, and standard application migrations. It SHALL provide no web UI, payment behavior, jobs, model calls or external services. The framework gem SHALL exclude both reference applications and their databases, while the support desk remains v1.

#### Scenario: Package inspection
- **WHEN** the framework gem is built
- **THEN** neither reference application's files or databases are included
