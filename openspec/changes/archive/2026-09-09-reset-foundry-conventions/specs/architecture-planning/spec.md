## ADDED Requirements

### Requirement: Context refactoring assessment
Context refactoring planning SHALL report the current and proposed profile, source locations and required manual migration work without rewriting business code or treating inferred runtime behavior as proven.

#### Scenario: Profile change assessment
- **WHEN** a context refactoring plan targets domain
- **THEN** the report identifies relevant source and namespace changes and leaves context files unchanged

### Requirement: Consistent source migration evidence
Context refactoring SHALL share AST diagnostics and replacement guidance with native source checking while retaining its selected-context scope, including tests. Legacy findings SHALL remain advisory during planning. Malformed Ruby SHALL make the assessment incomplete and fail the command without writes.

#### Scenario: Namespaced and nested references
- **WHEN** a context contains Other::RailsAIFoundry::Operation and RailsAIFoundry::AI::Agent
- **THEN** only the latter matches a legacy API path and its full constant name is reported
- **AND** the report states that constant resolution and dynamic calls are not proven

#### Scenario: Unparseable context test
- **WHEN** Ruby in the selected context's tests cannot be parsed
- **THEN** the report sets complete to false and the CLI returns failure while preserving files

## REMOVED Requirements

### Requirement: Versioned questionnaire and plan
**Reason**: The unused 0.1 implementation is retired in the approved 0.2 breaking reset.
**Migration**: Use native context tooling and direct upstream APIs; see docs/migration-0.2.md. Later example and event recipes remain tracked in docs/implementation-program.md.

### Requirement: Advisory recommendations
**Reason**: The unused 0.1 implementation is retired in the approved 0.2 breaking reset.
**Migration**: Use native context tooling and direct upstream APIs; see docs/migration-0.2.md. Later example and event recipes remain tracked in docs/implementation-program.md.

### Requirement: Safe proposal and review
**Reason**: The unused 0.1 implementation is retired in the approved 0.2 breaking reset.
**Migration**: Use native context tooling and direct upstream APIs; see docs/migration-0.2.md. Later example and event recipes remain tracked in docs/implementation-program.md.

### Requirement: Combined preflight and resumable application
**Reason**: The unused 0.1 implementation is retired in the approved 0.2 breaking reset.
**Migration**: Use native context tooling and direct upstream APIs; see docs/migration-0.2.md. Later example and event recipes remain tracked in docs/implementation-program.md.
