## MODIFIED Requirements

### Requirement: Independent architecture dimensions
Context intent SHALL use schema 1, rails_native/modular/domain profiles, independent none/integration/event_sourced events and none/queries/read_model CQRS patterns. Capabilities SHALL be keyed selections. Defaults SHALL NOT silently promote another dimension.

#### Scenario: Independent event sourcing
- **WHEN** a rails_native context selects event_sourced events
- **THEN** its profile remains rails_native and the event choice remains explicit

#### Scenario: Unsupported profile
- **WHEN** intent selects a profile outside the supported enumeration
- **THEN** validation fails and lists the supported profiles

### Requirement: Topology has one owner
Context foundry.yml SHALL NOT contain package dependencies, privacy configuration. Validation SHALL read configuration without evaluating Rails, Ruby constants or ERB.

#### Scenario: Duplicate topology
- **WHEN** a context intent includes dependencies
- **THEN** validation fails and directs the author to package.yml

#### Scenario: Unsafe document
- **WHEN** configuration contains duplicate keys, aliases or a symbolic link
- **THEN** validation fails before mutation or execution

### Requirement: Native structural assessment
Native structural checking SHALL validate configuration and unique namespace ownership without loading Rails or application execution runtimes. It SHALL distinguish this evidence from upstream Packwerk boundary validation and behavioral tests.

#### Scenario: Existing accepted debt
- **WHEN** native checking inspects an application with Packwerk baselines
- **THEN** it leaves those baselines unchanged and reports that Packwerk boundary checks require separate execution

#### Scenario: Unrelated application configuration
- **WHEN** an application contains other configuration documents or package metadata
- **THEN** Foundry ignores them as architectural intent and preserves their bytes

