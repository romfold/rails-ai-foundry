## Purpose

Describe a context's architectural intent independently from package topology and application runtime configuration.

## ADDED Requirements

### Requirement: Generated component constants have one owner
Native component generation SHALL reject a constant claimed by another component receipt in the same context before writing files, including preview requests. It SHALL preserve existing edited implementations and permit distinct constants with the same leaf name. Receipt checking SHALL NOT be presented as complete runtime constant resolution.

#### Scenario: Cross-kind collision
- **WHEN** a modular context already has an operation named quote and model quote is requested
- **THEN** generation rejects the duplicate constant and identifies its existing receipt without changing files

#### Scenario: Distinct domain categories
- **WHEN** command quote and query quote are generated in a domain context
- **THEN** their distinct categorized constants are permitted and repeat generation remains safe

### Requirement: Independent architecture dimensions
Context intent SHALL use schema 1, rails_native/modular/domain profiles, independent none/integration/event_sourced events and none/queries/read_model CQRS patterns. Capabilities SHALL be keyed selections. Defaults SHALL NOT silently promote another dimension.

#### Scenario: Independent event sourcing
- **WHEN** a rails_native context selects event_sourced events
- **THEN** its profile remains rails_native and the event choice remains explicit

#### Scenario: Legacy profile
- **WHEN** intent selects mvp or an event_sourced profile
- **THEN** validation fails with the replacement profile or pattern syntax

### Requirement: Topology has one owner
Context foundry.yml SHALL NOT contain package dependencies, privacy configuration or competing metadata.foundry declarations. Validation SHALL read configuration without evaluating Rails, Ruby constants or ERB.

#### Scenario: Duplicate topology
- **WHEN** a context intent includes dependencies
- **THEN** validation fails and directs the author to package.yml

#### Scenario: Unsafe document
- **WHEN** configuration contains duplicate keys, aliases or a symbolic link
- **THEN** validation fails before mutation or execution

### Requirement: Application defaults remain independent
Root configuration SHALL validate workload and context defaults without changing installed contexts. Generation SHALL use configured defaults unless explicitly overridden. Workload SHALL NOT imply profile, event or CQRS changes.

#### Scenario: Explicit profile override
- **WHEN** generation overrides a configured domain default with modular
- **THEN** the new context uses modular and retains independently configured pattern defaults

#### Scenario: Invalid root settings
- **WHEN** workload or context defaults contain unsupported values
- **THEN** setup and generation fail before mutation with corrective diagnostics

### Requirement: Native structural assessment
Native structural checking SHALL validate configuration and unique namespace ownership without loading Rails, the legacy manifest graph or application execution runtimes. It SHALL distinguish this evidence from upstream Packwerk boundary validation and behavioral tests.

#### Scenario: Existing accepted debt
- **WHEN** native checking inspects an application with Packwerk baselines
- **THEN** it leaves those baselines unchanged and reports that Packwerk boundary checks require separate execution

#### Scenario: Legacy manifest
- **WHEN** native checking encounters config/architecture.yml
- **THEN** it rejects the legacy manifest with manual adoption guidance rather than using the old dependency graph

### Requirement: Native scaffolds preserve application ownership
Context and component generation SHALL preserve existing consumer roots and produce files in the owning context using its configured namespace and profile. Repeated complete generation SHALL preserve user edits. Collisions, partial scaffolds and unsafe paths SHALL fail without overwriting user content. Preview SHALL make no application changes.

#### Scenario: Existing consumer root
- **WHEN** an application creates a context under its existing custom package root
- **THEN** discovery and component generation use that root without creating a competing inventory

#### Scenario: Edited repeat and collision
- **WHEN** a user repeats a complete generated component after editing its behavior
- **THEN** the edited content is preserved
- **AND** an incompatible or partial scaffold fails without overwriting existing files

### Requirement: Native command results preserve transactional failure
Generated transactional commands SHALL return one operation result to their caller and roll back writes when that result is a failure. A failed nested command SHALL roll back its own writes without implicitly deciding the fate of the caller's larger transaction. Ordinary operation scaffolds SHALL NOT silently open database transactions. Application code SHALL execute without a Foundry execution runtime.

#### Scenario: Failed result after a write
- **WHEN** an implemented generated command writes a record and returns a failure result
- **THEN** its caller receives that failure and the command's write is rolled back

#### Scenario: Nested failure
- **WHEN** a generated command fails inside an outer transaction that has already written a record
- **THEN** the command's writes are rolled back while the caller retains control over committing or aborting its own write
