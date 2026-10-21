## Purpose

Define explicit framework verification commands, reset isolation, and the optional application-owned AI execution-store interface.

## ADDED Requirements

### Requirement: Combined static verification command
The framework SHALL expose `bin/rails foundry:check` to run structural, convention, and package-boundary verification without initializing the application or executing package code. Invalid configuration or violations SHALL produce actionable diagnostics and a nonzero exit status.

#### Scenario: Check a hostile-to-boot application
- **WHEN** foundry:check runs against a valid registered application whose environment raises if initialized
- **THEN** the command succeeds without loading the environment or package code

#### Scenario: Invalid package boundary
- **WHEN** a source reference violates a declared boundary
- **THEN** foundry:check reports the violation and fails

### Requirement: Explicit projection rebuild command
The framework SHALL expose `bin/rails 'foundry:projections:rebuild[package,name]'` to initialize the application and rebuild the named registered projection, retaining the existing transactional rollback and stream-preservation guarantees. Missing arguments SHALL report the expected command syntax.

#### Scenario: Rebuild a registered projection
- **WHEN** the command identifies a registered projection and valid stored events
- **THEN** its owned read models are rebuilt and completion identifies the package and projection

#### Scenario: Missing arguments
- **WHEN** the rebuild command lacks its package or name argument
- **THEN** it fails with actionable command syntax instead of selecting another projection

### Requirement: Owned runtime reset
`RailsAIFoundry::Runtime.reset!` SHALL clear Foundry-owned containers and event-store references without clearing unrelated application or global state. Subsequent preparation SHALL resolve the current application compositions.

#### Scenario: Successive preparation cycles
- **WHEN** an application prepares, resets, and prepares again with updated composition classes
- **THEN** runtime lookup returns newly built containers and no stale Foundry event-store reference
- **AND** unrelated global state remains intact

### Requirement: Optional execution-store interface
The optional AI API SHALL provide `RailsAIFoundry::AI::ExecutionStore` describing `transaction_open?`, `start(attributes)`, and `finish(execution_id, attributes)`, and a `NullStore` performing no persistence. Existing stores SHALL remain accepted through duck typing without inclusion or inheritance.

#### Scenario: Use a store without interface inclusion
- **WHEN** an existing store implements the three methods
- **THEN** tracked execution continues using that store without an ancestry requirement

#### Scenario: Disable execution persistence
- **WHEN** tracking uses NullStore
- **THEN** it reports no open transaction and performs no persistence or external operations
