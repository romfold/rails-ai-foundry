# integrated-knowledge Specification

## Purpose

Provide executable evidence that a tenant-scoped knowledge application preserves authorization, consistency and recoverability across independently committed systems.

## Requirements

### Requirement: Atomic knowledge changes
Document editing, publication, withdrawal and deletion SHALL preserve tenant authorization and optimistic revision checks. State and publication intent SHALL commit or roll back together, including nested failures.

#### Scenario: Concurrent or failed write
- **WHEN** a command uses an outdated revision or fails after writing state
- **THEN** no partial state or publication intent commits

### Requirement: Recoverable independent deliveries
Committed intent SHALL remain recoverable across process crashes, duplicate publication, expired leases and independent destination failures. Conflicting event identities and poison messages SHALL require explicit repair.

#### Scenario: Publication committed before acknowledgment
- **WHEN** the publisher crashes after the event destination commits
- **THEN** retry verifies the existing event and completes without duplicate destination effects

#### Scenario: Worker loses its lease
- **WHEN** a claimed job expires and a second worker completes it
- **THEN** the old worker cannot acknowledge or overwrite the newer worker's delivery state

### Requirement: Current authorized projections
Search and retrieval SHALL return only authorized, currently published document revisions and the selected embedding version. Reordered delivery SHALL NOT restore deleted or withdrawn content. Provider work SHALL occur outside database transactions.

#### Scenario: Document changes during embedding
- **WHEN** embedding finishes for an obsolete revision
- **THEN** the obsolete vectors are rejected and current authoritative visibility governs results

### Requirement: Verified rebuild and cutover
Search and vector rebuilds SHALL retain the active version until a candidate passes completeness and revision validation. Concurrent changes and interrupted rebuilds SHALL be recoverable without exposing an invalid candidate.

#### Scenario: Candidate validation fails
- **WHEN** a rebuild cannot reconcile concurrent edits or deletions
- **THEN** the active index or embedding version remains selected

### Requirement: Offline application and evidence
The application SHALL provide document management, indexing status, search and cited answering through Rails delivery using deterministic offline providers by default. Tools SHALL enforce authorization in application code and answers SHALL reject invalid citations. Independent acceptance SHALL exercise real local persistence and search services without live model calls.

#### Scenario: Unavailable provider or unauthorized citation
- **WHEN** answering fails or returns evidence outside the authorized current result set
- **THEN** the application reports failure without returning unauthorized content
