## Purpose

Provide reproducible evidence about coding-agent behavior with Foundry guidance, separating behavioral correctness from architectural checks and runtime samples.

## ADDED Requirements

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

### Requirement: Bounded authorized pilot
The local pilot SHALL use Cursor CLI 2026.09.15-d2fe57e with Composer 2.5 (composer-2.5), without a separately configurable reasoning effort and workflow none for boundary extraction and stale-embedding repair. It SHALL schedule three repetitions per task and comparison group, eighteen serial trials total, with ten minutes per trial and three hours total agent execution. Existing Cursor browser authentication SHALL be used without additional paid API calls. Authentication or quota failure SHALL stop the pilot without resets, substitutions or extra trials.

#### Scenario: Authentication or quota failure
- **WHEN** a trial encounters authentication or quota failure
- **THEN** its actual outcome and remaining unstarted trials are recorded
- **AND** no automatic reset or replacement run occurs

### Requirement: Honest revision-specific evidence
Reports SHALL identify frozen input, skill, gem, model and runtime versions and distinguish failed trials, timeouts, interventions, unknown usage and unknown monetary cost. Subsequent fixes SHALL NOT imply measured improvement without another experiment. Offline grading SHALL have its own CI lane; local agent trials SHALL require explicit activation.

#### Scenario: Post-pilot guidance fix
- **WHEN** evidence leads to a guidance or tooling repair
- **THEN** regression coverage is added and the measured revision remains separately identified

#### Scenario: Corrected grading after measurement
- **WHEN** a grader defect is repaired after the measured run
- **THEN** original outcomes remain preserved and corrected outcomes identify the revised grader
- **AND** regraded candidates retain the original final source hashes without additional agent trials
