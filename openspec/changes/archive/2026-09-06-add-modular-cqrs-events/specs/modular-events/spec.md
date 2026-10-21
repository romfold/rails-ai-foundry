## Purpose

Deliver local command/query and business-event workflows while preserving database state as the authoritative model.

## ADDED Requirements

### Requirement: Commands and queries have distinct behavior

Event-enabled profiles SHALL generate canonical commands and queries using the application result contract. Commands SHALL commit business writes only on success; failure results and exceptions SHALL roll back. Queries SHALL prevent writes through the configured Active Record connection while permitting reads.

#### Scenario: Failed command

- **WHEN** a command writes a model and subsequently returns a failure result
- **THEN** its writes are rolled back and the failure result remains visible

#### Scenario: Query attempts a write

- **WHEN** a generated query implementation attempts an Active Record write
- **THEN** execution fails and no write is persisted

### Requirement: Optional event setup preserves consumer changes

An explicit event installer SHALL require a compatible consumer event dependency and an event-enabled package. It SHALL create host migrations and initialization through conservative receipts, preserve modified complete output on repeats, support preview, reject conflicts before writes, and never apply migrations automatically. Core require and MVP workflows SHALL not load the event runtime.

#### Scenario: Missing dependency

- **WHEN** event setup is requested without its consumer dependency
- **THEN** it reports the dependency and installation command without creating partial files

### Requirement: Versioned events remain independent of persistence

Event contracts SHALL have stable identifiers, explicit types and versions, immutable JSON-compatible data, and no Rails dependency. Persistence adapters SHALL map those contracts to stored records. Unknown event types and unsupported versions SHALL fail with actionable diagnostics instead of constructing arbitrary classes.

#### Scenario: Read unsupported event version

- **WHEN** a stored event version is not supported by its explicitly registered contract
- **THEN** reading fails and identifies the type and version without modifying the stream

### Requirement: Atomic local publication

Business-event publication and synchronous local handlers SHALL use the same database transaction as command writes. Database state SHALL remain authoritative in modular and domain profiles. Failure results, handler exceptions, and transaction rollback SHALL leave no committed business writes or events from that command.

#### Scenario: Handler fails

- **WHEN** a synchronous handler raises after event persistence
- **THEN** the command's business writes and event are rolled back together

### Requirement: Explicit subscription ownership and reload

Publishing SHALL be restricted to a package's registered event contracts. A subscriber SHALL name its consumer package and public event contract, with an explicit dependency on another publishing package. Own private domain events SHALL be available only within their package. Rails reload SHALL replace subscriptions and component references without duplicate handling.

#### Scenario: Undeclared subscription

- **WHEN** a consumer subscribes to another package without a declared dependency or references a private domain event
- **THEN** registration fails with the consumer, owner, and required public contract guidance

#### Scenario: Reload handlers

- **WHEN** Rails reloads event handlers twice
- **THEN** one publication invokes each registered handler once using the current class
