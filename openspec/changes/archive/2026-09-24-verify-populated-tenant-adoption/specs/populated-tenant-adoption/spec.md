## Purpose

Demonstrate safe tenant ownership adoption in populated Rails tables through independently verified application-owned checkpoints.

## ADDED Requirements

### Requirement: Independently useful populated extraction
The tenant-backfill scenario SHALL characterize a legacy collection-owned document application, extract Knowledge and repair callers before changing document ownership persistence. It SHALL preserve existing identity, revisions, business content, timestamps, authorization, workflow history and accepted debt in both default and custom package roots.

#### Scenario: Extract existing data
- **WHEN** the extraction checkpoint runs against at least 1,200 documents across three tenants
- **THEN** HTTP behavior and data remain equivalent and an intentional boundary violation fails before repair

### Requirement: Recoverable ownership backfill
Compatible writers SHALL derive ownership from trusted collections. Backfill SHALL process at most 250 rows per transaction, preserve atomic progress, serialize workers and recover after process interruption. Unresolved ownership SHALL remain concealed and require reviewed repair; request-supplied ownership SHALL NOT be trusted.

#### Scenario: Interrupted batch with concurrent writes
- **WHEN** backfill crashes while normal documents are created, updated or deleted
- **THEN** restart preserves committed progress and completes without skipped or corrupted ownership

#### Scenario: Unresolved imported record
- **WHEN** a document lacks trusted ownership
- **THEN** it is inaccessible, its safe identifier/reason is reported and completion remains blocked

### Requirement: Validated bounded cutover
Cutover SHALL require validated ownership presence and collection consistency. It SHALL use a five-second writer-gate acquisition timeout and ten-second checked budget without backfilling or full scans in the pause. Failures SHALL preserve legacy read selection. Compatible rollback SHALL retain additive data and operational records.

#### Scenario: Incomplete migration
- **WHEN** ownership is incomplete, inconsistent or validation is unfinished
- **THEN** cutover refuses without changing the active read mode

#### Scenario: Timeout or rollback
- **WHEN** the gate times out or the operator selects compatible rollback
- **THEN** legacy reads remain usable and committed ownership data is retained

### Requirement: Installed behavioral evidence
The scenario SHALL run from installed Foundry guidance in disposable consumers and prove populated migration, fresh schema preparation and recovery. Faulty ownership assignment, skipped batches, unsafe activation and authorization bypass SHALL fail behavioral assertions.

#### Scenario: Installed custom-root replay
- **WHEN** the scenario runs with components instead of packs
- **THEN** both correct behavior and fault rejection are verified without advanced persistence or provider dependencies
