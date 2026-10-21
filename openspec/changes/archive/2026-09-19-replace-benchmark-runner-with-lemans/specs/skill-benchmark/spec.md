## ADDED Requirements

### Requirement: Upstream benchmark execution and separate corpora
Contributor tooling SHALL pin Le Mans and the complete 42-task Rails AI-evals corpus independently of production dependencies. It SHALL retain six Foundry tasks across the three existing groups and all 45 controls. Upstream smoke, atomic, feature and Foundry results SHALL remain distinguishable. Native agents SHALL require separately authorized live execution; checked-in defaults SHALL run offline controls.

#### Scenario: Full corpus preparation
- **WHEN** an external workspace is prepared
- **THEN** pinned tasks and notices remain unchanged and all 42 tasks are inventoried
- **AND** resolved images, dependency and input hashes are recorded without exposing references or historical runs to candidates

#### Scenario: Removal gate
- **WHEN** any upstream reference fails verification or an existing Foundry control loses parity
- **THEN** the migration remains incomplete and the old runner is retained
- **AND** no task is silently omitted or weakened

### Requirement: Fresh verification of captured changes
Final changes SHALL be reconstructed from a sealed baseline and complete patch in a fresh offline credential-free container. Native and independent grades SHALL be preserved separately, with disagreements blocking acceptance. Protocol violations, missing evidence and infrastructure failures SHALL NOT count as credited passes. Package outcomes SHALL remain separate from shared behavior.

#### Scenario: Modified grading surface
- **WHEN** a candidate edits a protected file or disables required assertions
- **THEN** the attempt is not credited and trusted evaluator assets remain authoritative

#### Scenario: Incomplete or sanitized patch
- **WHEN** a patch is missing, incomplete or cannot reconstruct after secret filtering
- **THEN** verification records unavailable or non-replayable evidence rather than a passing grade

### Requirement: Immutable migration evidence
Historical pilot files SHALL remain byte-identical. Derived grades SHALL use separate output directories. Artifact writes SHALL filter configured secrets before persistence. Reports SHALL distinguish attempted, valid, failed, invalid and infrastructure outcomes and SHALL NOT equate local corpus validation with the upstream leaderboard.

#### Scenario: Regrading a saved candidate
- **WHEN** independent verification is repeated with a changed grader
- **THEN** a new attributed result is created without overwriting original outcomes

## REMOVED Requirements

### Requirement: Bounded authorized pilot
**Reason**: The authorized pilot is completed historical evidence, not the active execution interface.
**Migration**: Preserve its original records and reproduction revisions. Future native Le Mans experiments require separate authorization and budgets; no replacement trial is included in this change.
