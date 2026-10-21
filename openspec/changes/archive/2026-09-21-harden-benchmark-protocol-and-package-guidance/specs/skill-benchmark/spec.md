## ADDED Requirements

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
