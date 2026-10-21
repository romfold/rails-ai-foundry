## Purpose

Support incremental adoption with complete debt identities and application-specific parity evidence.

## ADDED Requirements

### Requirement: Disposable debt audit
Debt audit SHALL regenerate upstream debt only in disposable application copies, report new, retained and resolved violation identities, preserve source baseline bytes, and fail on new debt or failed upstream analysis.

#### Scenario: Resolved baseline
- **WHEN** all references behind an accepted violation have disappeared
- **THEN** audit reports the resolved identities even if ordinary upstream checking misses the stale file

### Requirement: Application parity
Parity verification SHALL compare Packwerk and pks identities on the same application snapshot, record tool and input fingerprints, and reject mismatched or stale evidence. Packwerk SHALL remain authoritative; pks SHALL never become the default merely because it is installed.

#### Scenario: Parity mismatch
- **WHEN** pks omits or adds a violation relative to Packwerk
- **THEN** verification fails and does not enable it

### Requirement: Adoption inventory
Read-only adoption SHALL identify upstream packages, existing workflow and baseline identities with incremental extraction guidance without modifying application files.

#### Scenario: Existing roots
- **WHEN** adoption inspects an existing application
- **THEN** its roots, workflow and accepted debt remain unchanged
