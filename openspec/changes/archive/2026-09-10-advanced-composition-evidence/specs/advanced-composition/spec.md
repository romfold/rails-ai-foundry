## Purpose

Provide optional composition recipes that retain native results and explicit database atomicity.

## ADDED Requirements

### Requirement: Atomic composed writes
The ROM recipe SHALL commit business state and publication intent through one gateway transaction, roll back failed native operation results and nested failures, and publish only after commit with duplicate-safe recovery.

#### Scenario: Failed operation
- **WHEN** a composed write fails after storing business data
- **THEN** neither state nor publication intent commits

### Requirement: Optional composition
Constructor injection SHALL remain the default. Optional DI and workflow recipes SHALL use upstream execution directly, preserve their native result boundaries and have isolated dependency locks and executable checks.

#### Scenario: Recipe opt-in
- **WHEN** an application chooses a composition recipe
- **THEN** unselected applications need no new runtime dependencies
