## MODIFIED Requirements

### Requirement: Package-owned scaffold
The command bin/rails generate foundry:agent NAME --package PACKAGE SHALL generate a namespaced agent, delegated tool, string-result schema, plain-text instructions, and package-local tests for an existing structurally valid domain or platform package. Manifest-v1 output and receipts SHALL remain unchanged. Manifest-v2 classes SHALL use the profile registry external-adapter location and ordinary filename-to-constant namespaces, with package tests mirroring that responsibility. No optional dependency SHALL be installed by generation.

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

#### Scenario: Profile-compatible scaffold
- **WHEN** an agent is generated in any of the four profiles, including a platform package
- **THEN** its Ruby sources use canonical external adapters, strict checks pass, and configured Rails loading supports lazy loading, eager loading, and reloading without provider requests

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

#### Scenario: Previously generated legacy layout in a profiled package
- **WHEN** a profiled package contains the requested agent's legacy files or incompatible receipt
- **THEN** generation and preview fail before writes with manual reconciliation guidance and preserve all existing files

## ADDED Requirements

### Requirement: Profiled AI layer isolation

Static conventions SHALL reject direct RubyLLM constants and requires from profiled application and domain objects and projection handlers. Composition and public APIs SHALL remain the allowed locations for container resolution. Checks SHALL not load RubyLLM or execute package code.

#### Scenario: Direct provider coupling
- **WHEN** a profiled application operation, domain entity, or projection directly references RubyLLM
- **THEN** conventions fail with guidance to use external adapters and injected dependencies

#### Scenario: Injected integration
- **WHEN** composition injects an external AI adapter into an application port and public callers use the owned API
- **THEN** static conventions pass without provider access
