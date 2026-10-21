## Purpose

Generate safe, reusable agent scaffolds inside registered packages while preserving application ownership and existing configuration.

## ADDED Requirements

### Requirement: Package-owned scaffold
The command bin/rails generate foundry:agent NAME --package PACKAGE SHALL generate a namespaced agent, delegated tool, string-result schema, plain-text instructions, and package-local tests for an existing structurally valid domain or platform package.

#### Scenario: Domain and platform ownership
- **WHEN** summarize is generated in a registered support or platform package
- **THEN** classes use the corresponding package namespace and the manifest and metadata remain byte-identical

#### Scenario: Invalid input
- **WHEN** the name is unsafe, the package is unregistered, or structural validation fails
- **THEN** generation fails before writing

#### Scenario: Injected behavior
- **WHEN** a generated tool receives an application operation
- **THEN** its query is delegated to that operation without generated business logic

#### Scenario: File instructions
- **WHEN** a chat is built from a generated agent
- **THEN** its package-local plain-text instructions are read independently of the working directory and are not evaluated as Ruby or ERB

### Requirement: Conservative generation
Generation SHALL preflight every destination and preserve existing content. A complete previously generated scaffold SHALL be reported as existing; conflicts and partial scaffolds SHALL fail. Dry runs SHALL write nothing; force SHALL NOT bypass safeguards; automatic reversal SHALL fail.

#### Scenario: Repeated customization
- **WHEN** an exact request is repeated after generated content is customized
- **THEN** all customized content is preserved and existing artifacts are reported

#### Scenario: Conflict or partial scaffold
- **WHEN** any destination exists without a matching complete generation receipt
- **THEN** the request fails without overwrites

#### Scenario: Unsafe paths
- **WHEN** a destination or ancestor is a symlink or wrong filesystem type
- **THEN** generation fails without writing outside the package

#### Scenario: Dry run and reversal
- **WHEN** pretend or automatic reversal is requested
- **THEN** pretend reports planned artifacts without writes and reversal fails

#### Scenario: Write failure
- **WHEN** writing fails after some new artifacts were created
- **THEN** unchanged newly created artifacts are removed, concurrent edits are preserved, and the failure is actionable
