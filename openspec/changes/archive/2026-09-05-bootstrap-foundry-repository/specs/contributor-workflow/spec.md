## Purpose

Give contributors and coding agents a reproducible, discoverable workflow for developing Rails AI Foundry while clearly separating implemented behavior from proposed capabilities.

## ADDED Requirements

### Requirement: Reproducible contributor tooling

The repository SHALL provide a project-local, exactly pinned specification tool, a dependency lockfile, a documented supported Node setup, and a command to validate all active changes and baseline specifications in strict, non-interactive mode.

#### Scenario: Set up a clean checkout

- **WHEN** a contributor selects the documented Node version and runs `npm ci`
- **THEN** the pinned OpenSpec CLI is available through `npm run openspec -- --version` without a global installation
- **AND** `npm run spec:validate` validates all active changes and baseline specifications

#### Scenario: Invalid specification

- **WHEN** an active change contains a requirement without a scenario
- **THEN** `npm run spec:validate` exits unsuccessfully and identifies the invalid specification

### Requirement: Discoverable English guidance

The repository SHALL provide English setup, contribution, architecture, roadmap, and agent guidance reachable from its README. Project-authored documentation, specifications, comments, identifiers, and commit messages MUST use English. Shared OpenSpec skills SHALL be available in the repository's generic agent skill directory.

#### Scenario: Contributor or agent joins the project

- **WHEN** a contributor reads the README or an agent reads the root agent instructions
- **THEN** they can locate the contribution workflow, authoritative specifications, architecture direction, and validation command
- **AND** they can discover the installed shared OpenSpec workflows without a vendor-specific configuration

### Requirement: Explicit capability status

Project guidance SHALL distinguish implemented behavior, proposed changes, and roadmap ideas. Research input SHALL remain contextual material and SHALL NOT automatically become project instructions or implemented requirements.

#### Scenario: Inspect framework availability

- **WHEN** a contributor reads the foundation README and roadmap
- **THEN** they see that contributor tooling is available and the framework runtime is planned
- **AND** research-derived ideas are labeled as intended direction or future work

### Requirement: Spec-driven change lifecycle

Contribution guidance SHALL describe proposals, behavior specifications, design, implementation tasks, validation, and archive. Baseline specifications SHALL describe completed behavior; unfinished runtime proposals MUST remain active with their implementation tasks unchecked.

#### Scenario: Complete the foundation

- **WHEN** the foundation artifacts and implementation have passed their verification checks
- **THEN** its completed tasks and artifacts are archived and its contributor-workflow requirements appear in the baseline specifications

#### Scenario: Prepare an unimplemented feature

- **WHEN** the architecture-core proposal is prepared without implementing the runtime
- **THEN** it remains an active change with all implementation tasks unchecked
- **AND** its proposed capabilities do not appear as implemented baseline specifications

### Requirement: Documented commit convention

Contribution guidance SHALL require English Conventional Commits using `type(scope): description`, with scope optional and breaking changes explicitly marked. The repository SHALL NOT install commit hooks or automated commit-message enforcement in this milestone.

#### Scenario: Record repository work

- **WHEN** a contributor follows the commit guidance
- **THEN** they can choose an appropriate commit type and optional scope using documented examples
- **AND** installing the development dependencies does not install a commit hook
