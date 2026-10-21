# Bounded knowledge operations specification

## Purpose

Make the integrated knowledge application bounded and recoverable as its dataset grows, and turn the demonstrated behavior into reusable verification guidance.

## Requirements

### Requirement: Bounded authorized reads
Document listing, delivery-status lookup and retrieval SHALL bound application-materialized rows independently of total corpus size. Retrieval SHALL select the authorized tenant and active embedding version before candidate materialization, revalidate authoritative publication and revision, and disclose when a work limit prevents filling the requested result count.

#### Scenario: Many stale or foreign candidates
- **WHEN** retrieval encounters foreign-tenant, obsolete, withdrawn or deleted candidates
- **THEN** none is returned as a current authorized result
- **AND** scanning stops at the configured candidate budget with an explicit incomplete outcome if necessary

#### Scenario: Large document list
- **WHEN** a tenant has more documents than one page
- **THEN** listing and delivery status materialize only the requested bounded page and its associated status records
- **AND** traversal uses a stable cursor without loading all tenant identifiers

### Requirement: Durable rebuild progress
Search and embedding rebuilds SHALL retain candidate identity, progress and ownership across process restarts. A resumed run SHALL replay uncertain work safely, preserve authoritative business data and reject stale-worker progress updates. Missing candidates or incompatible rebuild parameters SHALL fail explicitly rather than silently restart against a different target.

#### Scenario: Crash after destination write
- **WHEN** a worker exits after writing a batch but before recording progress
- **THEN** a replacement resumes the same candidate, safely replays that batch and advances only after successful delivery

#### Scenario: Ownership expires
- **WHEN** another worker claims an expired rebuild
- **THEN** the previous worker cannot advance progress, initiate a new activation or revert a newer completed selection

### Requirement: Complete concurrent catch-up
A rebuild SHALL account for creates, edits, publication, withdrawal and deletion committed during backfill, including changes behind its page cursor. Candidate validation SHALL compare expected identities, revisions and contents with bounded application memory. Missing change history SHALL block activation.

#### Scenario: Mutation behind a completed page
- **WHEN** a document changes after its page was processed or a new identifier sorts before the current cursor
- **THEN** catch-up applies the committed change before activation
- **AND** obsolete work cannot resurrect withdrawn or deleted content

### Requirement: Bounded and reconciled activation
The final writer pause SHALL enforce documented work and time budgets without a full-corpus rescan or provider calls. A failed pre-cutover validation or budget check SHALL retain the active projection. An uncertain external cutover response SHALL remain unresolved until the actual destination is inspected; the application SHALL NOT falsely report either success or unchanged selection.

#### Scenario: Catch-up exceeds the final budget
- **WHEN** the remaining changes cannot be validated within the final pause budget
- **THEN** activation does not start, normal writes resume, and the run remains recoverable

#### Scenario: Cutover succeeds but acknowledgment is lost
- **WHEN** the destination changes selection but its response or local completion update is lost
- **THEN** recovery inspects the actual selection and reconciles the same run
- **AND** retries cannot revert a newer completed selection

### Requirement: Recoverable operator actions
Trusted operators SHALL be able to inspect, resume and cancel rebuilds using application-owned interfaces. Operational signals SHALL expose progress, lag, retries, lease recovery, incomplete retrieval and cutover state without document content, user questions or credentials. Cleanup SHALL be explicit and refuse active, unresolved or leased candidates.

#### Scenario: Cancellation and cleanup
- **WHEN** an operator cancels a run during processing
- **THEN** it stops acquiring new work, preserves the active projection and records a terminal or reconciliation-required state
- **AND** cleanup requires verified inactive ownership and a dry-run preview

### Requirement: Executable and reusable evidence
Acceptance SHALL exercise real disposable persistence/search services with deterministic providers, process interruption and both valid and faulty implementation controls. Scale evidence SHALL record dataset sizes, resource budgets, revisions, commands and measured outcomes independently of agent benchmark results. Existing product skills SHALL reference the demonstrated behavioral and recovery checks without treating static success as proof of behavior or imposing a public-service boundary on every same-pack Rails operation.

#### Scenario: Green package checks with wrong behavior
- **WHEN** an implementation satisfies structural rules but violates its declared entrypoint, tenant or recovery contract
- **THEN** behavioral acceptance fails
- **AND** equivalent direct, delegated or relocated valid implementations pass

#### Scenario: Installed guidance
- **WHEN** the packaged verification guidance is replayed in a disposable consumer with a custom package root
- **THEN** its commands and assertions work against the installed gem and preserve the selected specification workflow and accepted debt
