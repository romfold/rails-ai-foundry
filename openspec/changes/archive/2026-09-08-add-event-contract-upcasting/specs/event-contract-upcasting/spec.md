## Purpose

Allow explicitly supported historical event payloads to evolve at read time while preserving authoritative stored records and current immutable contracts.

## ADDED Requirements

### Requirement: Explicit owned consecutive transitions
Applications SHALL declare optional event upcasters in package composition, defaulting to no transitions. Each declaration SHALL identify TYPE, positive integer from/to versions with to equal to from plus one, and a callable payload transformation. Registration SHALL reject unknown types, cross-owner declarations, duplicate source steps, ambiguous or incomplete chains, and transitions beyond the current contract.

#### Scenario: Multi-step chain
- **WHEN** an owner registers transitions 1 to 2 and 2 to 3 for its current version 3 contract
- **THEN** historical versions 1 and 2 are supported through the complete chain

#### Scenario: Invalid chain
- **WHEN** declarations duplicate a source version, skip a version, target an unknown type, belong to another package, or cannot reach the current contract
- **THEN** registration fails with an actionable ContractError

### Requirement: Data-only read-time evolution
Decoding SHALL construct the current immutable contract after applying its supported historical transitions. Encoding SHALL accept only the one current registered contract per TYPE. Upcasting SHALL preserve event IDs, types, metadata, ordering and stream positions and SHALL NOT modify stored records. Historical versions without complete registered support SHALL fail.

#### Scenario: Mixed-version replay
- **WHEN** a stream contains current and supported historical events
- **THEN** replay observes current immutable payloads in the original order with unchanged IDs and metadata
- **AND** stored records remain byte-identical

#### Scenario: No transition registered
- **WHEN** a historical payload lacks a complete registered chain
- **THEN** reading fails with its type/version and registration guidance without modifying the stream

### Requirement: Validated transformations and bounded diagnostics
Each transformation output SHALL satisfy existing JSON-compatible payload rules. Transformation failures SHALL identify type and transition without exposing payload contents. Projection rebuild failures SHALL retain existing transaction rollback. Applications SHALL commit historical fixtures for every supported transition and document transformations as deterministic code without IO; static checking SHALL NOT claim to prove compatibility or purity.

#### Scenario: Malformed transformed output
- **WHEN** a transformation returns cyclic, nonfinite, or otherwise non-JSON data
- **THEN** decoding fails with a sanitized ContractError naming the transition

#### Scenario: Transformation raises during rebuild
- **WHEN** a transformation raises after a rebuild has processed earlier events
- **THEN** read-model and processing-record changes roll back and stored event data remains unchanged
- **AND** the error does not expose payload values through its message or exception cause
