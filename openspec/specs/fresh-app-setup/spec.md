# fresh-app-setup Specification

## Purpose
Compose the installed framework into a normal Rails application without prescribing unrelated application capabilities.

## Requirements

### Requirement: Native application creation
The foundry new command SHALL delegate application creation to the installed Rails generator, initialize the selected workflow and Foundry skills, and make Foundry a development/test dependency. Defaults SHALL be PostgreSQL, Puma, Hotwire and Solid Queue without an additional cache service. Generated application code SHALL load using ordinary Rails and upstream dependencies without Foundry in production.

#### Scenario: Greenfield default
- **WHEN** a new application is created without a workflow override
- **THEN** it selects Spec Kit without inheriting the parent repository's workflow

#### Scenario: Incomplete creation
- **WHEN** bundling, Rails integration or workflow setup fails
- **THEN** creation fails with an interruption marker and preserves generated files for inspection without claiming success

#### Scenario: Existing destination
- **WHEN** the target application directory already exists
- **THEN** creation refuses to overwrite it and directs the user to adoption or setup

#### Scenario: Upstream application execution
- **WHEN** development/test bundle groups are excluded in production
- **THEN** native generated components load without Foundry and continue to use their direct upstream APIs

### Requirement: Specification workflow setup command
Standalone setup SHALL accept spec-kit, openspec or none; publish the selection under workflow.specs in config/foundry.yml; and preserve unrelated configuration. A preview SHALL list the resolved selection and intended actions without writes.

#### Scenario: Preserve application policy
- **WHEN** setup changes the workflow in configuration containing workload and checker policy
- **THEN** those unrelated values remain unchanged

#### Scenario: Missing Rails application
- **WHEN** setup is invoked outside a consuming Rails application
- **THEN** it fails without creating an application configuration in the gem repository

### Requirement: Read-only native adoption
The foundry adopt command SHALL assess consuming application configuration without booting Rails, initializing workflow tools or writing files. It SHALL preserve existing roots and accepted debt and recommend OpenSpec only when no workflow is established.

#### Scenario: Established Spec Kit workflow
- **WHEN** adoption detects an application-local Spec Kit installation
- **THEN** it preserves that recommendation and leaves installed configuration and specifications unchanged

#### Scenario: Explicit assessment override
- **WHEN** adoption receives an explicit workflow selection
- **THEN** the report uses that selection without publishing it or converting specification history
