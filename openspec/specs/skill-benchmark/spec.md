# Skill benchmark Specification

## Purpose

Provide reproducible evidence about coding-agent behavior with Foundry guidance, separating behavioral correctness from architectural checks and runtime samples.

## Requirements

### Requirement: Frozen comparable tasks
The contributor benchmark SHALL provide six versioned knowledge tasks with frozen starting applications, identical behavioral requirements across three comparison groups, visible tests, withheld acceptance tests, verified references and deliberately faulty controls. Shared behavioral/security results SHALL be reported separately from package checks that do not apply to plain Rails.

#### Scenario: Grader controls
- **WHEN** reference and deliberately faulty solutions are graded
- **THEN** references pass and faulty solutions fail the relevant withheld requirements
- **AND** infrastructure failures are distinct from behavioral failures

#### Scenario: Equivalent delivery implementations
- **WHEN** a valid boundary implementation delegates through a delivery service or relocates its controller
- **THEN** grading verifies endpoint behavior and public API delegation without requiring one source path or literal call site
- **AND** delivery that ignores the public API result and queries persistence directly is rejected

### Requirement: Isolated independent evaluation
Candidate execution SHALL exclude evaluator tests, reference solutions, other trials and the Foundry repository from its accessible filesystem. Final candidates SHALL be graded independently in disposable environments, with execution limits and recorded hashes, diffs, tests, events, usage, duration and interventions. Completion messages SHALL NOT constitute correctness evidence.

#### Scenario: Candidate attempts evaluator access
- **WHEN** an isolation probe attempts to access evaluator files or another trial during candidate execution
- **THEN** those resources are unavailable
- **AND** grading occurs after candidate execution has stopped

### Requirement: Honest revision-specific evidence
Reports SHALL identify frozen input, skill, gem, model and runtime versions and distinguish failed trials, timeouts, interventions, unknown usage and unknown monetary cost. Subsequent fixes SHALL NOT imply measured improvement without another experiment. Offline grading SHALL have its own CI lane; local agent trials SHALL require explicit activation.

#### Scenario: Post-pilot guidance fix
- **WHEN** evidence leads to a guidance or tooling repair
- **THEN** regression coverage is added and the measured revision remains separately identified

#### Scenario: Corrected grading after measurement
- **WHEN** a grader defect is repaired after the measured run
- **THEN** original outcomes remain preserved and corrected outcomes identify the revised grader
- **AND** regraded candidates retain the original final source hashes without additional agent trials

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

### Requirement: Explicit bounded live study
Contributor tooling SHALL prepare exactly the authorized trial matrix with frozen inputs, model settings and resource budgets. Agent execution SHALL remain native upstream execution and SHALL require a dedicated limited provider key supplied outside candidate access and repository configuration.

#### Scenario: Preflight refuses unsafe execution
- **WHEN** credentials, accounting, routing, available allowance or frozen inputs cannot be verified
- **THEN** no eligible launch receipt is issued and no agent is started by preflight
- **AND** sanitized failure evidence identifies the reason

#### Scenario: Ordered single attempts
- **WHEN** a task was already reserved or a predecessor remains unverified
- **THEN** preflight rejects another launch rather than silently retrying or overlapping trials

### Requirement: Honest live study outcomes
Live reports SHALL distinguish behavioral failures, unscored resource stops, protocol violations, infrastructure errors and unstarted attempts. Smoke and upstream outcomes SHALL remain separate from Foundry group comparisons. Provider usage SHALL remain distinct from locally reported cost estimates.

#### Scenario: Partial candidate at a resource limit
- **WHEN** a native attempt reaches its cost, time or step limit
- **THEN** its incomplete outcome remains visible even if a diagnostic independent grade succeeds

#### Scenario: Missing authentication
- **WHEN** no usable key is available for an otherwise prepared study
- **THEN** reporting records unstarted trials and makes no claim that a model was evaluated

### Requirement: Attributed offline candidate repair
Saved trial repairs SHALL preserve original patches, outcomes and accounting and record independent baseline/candidate/repair hashes and fresh verification as human-assisted regression evidence. Repaired candidates SHALL NOT become new or improved native trial scores.

#### Scenario: Verified repair
- **WHEN** an offline repair passes unchanged task requirements and supplemental regression checks
- **THEN** separate evidence records repaired outcomes, original failing controls and intentionally faulty variants
- **AND** no provider or coding-agent call is made

### Requirement: Independently selected repair sets
Contributor repair preparation SHALL support named, separately attributed repair sets while preserving default first-study preparation. It SHALL validate selected study revision, upstream task, image and original candidate identity before preparing output and SHALL reject unknown sets or mismatched provenance.

#### Scenario: Selecting a later study repair
- **WHEN** the contributor selects the September 21 realtime repair set
- **THEN** only its verified candidate, repair patches and supplemental checks are prepared
- **AND** the first study's fixtures and all historical grades remain unchanged

#### Scenario: Mismatched reconstruction inputs
- **WHEN** the study, task, image or candidate differs from the selected repair provenance
- **THEN** preparation fails without claiming a valid repair workspace

#### Scenario: Repair equivalence
- **WHEN** a repair is accepted
- **THEN** applying its incremental patch to the original candidate reconstructs the same tree as its complete patch against the sealed baseline
- **AND** original upstream requirements remain unchanged and faulty controls fail behavioral assertions

### Requirement: Explicit protected-file guidance
Foundry comparison candidates SHALL receive the same clear instructions distinguishing immutable grading files from allowed new application tests. Protected-file edits SHALL remain invalid even when they add useful tests or preserve existing assertions. Upstream task requirements SHALL remain unchanged.

#### Scenario: Adding regression coverage
- **WHEN** a candidate needs a regression test
- **THEN** instructions direct it to a new unprotected test file and preserve existing grading files
- **AND** grading accepts permitted new tests without relaxing the protected-file policy

### Requirement: Continue after independently diagnosed protocol failure
A newly prepared study SHALL permit the next independent attempt after a non-smoke protected-file violation only when the native attempt completed, fresh task verification completed with recorded violations, original artifacts remain intact and accounting is valid. The violation SHALL retain invalid status and its cost. Missing evidence, infrastructure failures, grading disagreements, failed smoke and accounting failures SHALL continue to block execution.

#### Scenario: Useful tests added to a protected file
- **WHEN** independent verification completes and records that protected file as a protocol violation
- **THEN** the next separately budgeted attempt can proceed without crediting or retrying the invalid candidate

#### Scenario: Unverified or failed infrastructure
- **WHEN** task verification did not complete or native execution failed authentication
- **THEN** preflight refuses the next attempt even if a protocol violation is also present

#### Scenario: Historical frozen study
- **WHEN** tooling or instructions change after an old study was frozen
- **THEN** its original evidence remains unchanged and new tooling requires a new study workspace

### Requirement: Causal realtime repair controls
The guidance-study repair SHALL preserve its original candidate and paid outcomes, demonstrate the causes of missing publication and malformed deletion controls, and verify committed realtime changes with viewer authorization and draft preservation in three fresh offline environments.

#### Scenario: Repaired candidate acceptance
- **WHEN** the named guidance-study repair is verified
- **THEN** unchanged upstream checks and supplemental authorization, rollback, form and draft checks pass
- **AND** its original and six isolated faulty variants fail behavioral checks while a composer-preserving alternative passes
- **AND** the evidence identifies candidate, incremental repair, complete patch and equivalent reconstructed trees without changing paid scores

#### Scenario: Provenance mismatch
- **WHEN** selected study, task, image, original patch or repair fixture identity differs
- **THEN** preparation rejects the selection before creating output and preserves prior repair sets

### Requirement: Multi-candidate offline repair evidence
Named repair preparation SHALL support the September 22 study's realtime candidate and Foundry boundary companion with validated study, task, image, original patch and fixture hashes. Its acceptance SHALL distinguish the original schema failure, subsequent behavioral failures and repaired outcomes without modifying paid grades.

#### Scenario: Repaired applications
- **WHEN** both candidates are repaired offline
- **THEN** the boundary satisfies its requested profile and existing behavioral checks
- **AND** the realtime application loads a fresh database and passes unchanged upstream and supplemental checks in three fresh offline containers
- **AND** original and faulty controls remain failing evidence separately from successful repairs

#### Scenario: Companion provenance mismatch
- **WHEN** either candidate's task, image or original patch differs from recorded provenance
- **THEN** preparation fails before creating a workspace
- **AND** older named and default preparation remain available
