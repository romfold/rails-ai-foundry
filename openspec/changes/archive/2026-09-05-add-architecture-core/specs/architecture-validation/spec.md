## Purpose

Help developers detect structural architecture mistakes through a deterministic read-only command with useful diagnostics and automation-friendly exit behavior.

## ADDED Requirements

### Requirement: Architecture check has meaningful outcomes

`bin/rails foundry:architecture:check` SHALL exit with status 0 when the manifest, package layout, metadata, and declared dependency rules are valid, and status 1 for diagnosed configuration or structural failures. Its successful output SHALL name the structural scope and number of checked packages without claiming runtime or Ruby dependency analysis.

#### Scenario: Valid application structure

- **WHEN** the task runs against a valid two-package application
- **THEN** it reports structural success for two packages and exits 0

#### Scenario: Missing manifest

- **WHEN** the task runs in a host without `config/architecture.yml`
- **THEN** it exits 1 and reports that installation or explicit configuration is required

### Requirement: Check package registration and completeness

The checker SHALL detect missing declared package roots, missing required package paths, malformed package metadata, and any undeclared package root carrying `package.yml` beneath `packages/`. It SHALL ignore ordinary directories without package metadata unless the manifest declares them as a package. Discovery MUST NOT traverse symbolic links.

#### Scenario: Declared package is incomplete

- **WHEN** a registered package lacks its root, metadata, app directory, or public entry file
- **THEN** the checker reports the missing path as a structural failure

#### Scenario: Unregistered package exists

- **WHEN** an undeclared directory beneath `packages/` contains `package.yml`
- **THEN** the checker reports that package root as unregistered

#### Scenario: Non-package directory exists

- **WHEN** a directory beneath `packages/` has no package metadata and is not registered
- **THEN** its presence alone is not a structural failure

### Requirement: Diagnostics are actionable and repeatable

Expected configuration, parsing, and filesystem errors SHALL produce English diagnostics containing a stable rule identifier, an application-relative source path, the affected package or field when available, and a corrective description. Multiple independently detectable structural failures SHALL be reported together in deterministic order. Invalid manifest structure SHALL stop dependent package checks instead of producing misleading cascaded errors.

#### Scenario: Several packages have errors

- **WHEN** two packages have independently detectable structural failures
- **THEN** the command reports both with their paths and rule identifiers
- **AND** repeating the command on unchanged files yields the same ordered diagnostics

#### Scenario: Manifest cannot be parsed

- **WHEN** the manifest contains invalid YAML
- **THEN** the command reports the manifest parse error, including a line location when available
- **AND** it does not report fabricated package failures derived from the invalid manifest

### Requirement: Validation does not modify or execute application content

The checker MUST NOT write files, instantiate tagged configuration objects, evaluate templates, load package Ruby files, boot the full application environment, or call external services. It SHALL report unreadable required inputs as diagnostics. The host's ordinary task-loading process is outside this promise; Foundry MUST NOT add environment boot as a task prerequisite.

#### Scenario: Validate offline

- **WHEN** the task runs in a minimal Rails host with network access unavailable and no database credentials
- **THEN** it validates local configuration and package files without attempting external connections

#### Scenario: Preserve the inspected application

- **WHEN** the checker runs on a valid or invalid package structure
- **THEN** file contents are unchanged after the run
- **AND** Ruby code in package entry files has not been executed

#### Scenario: Required input is unreadable

- **WHEN** a required configuration or package file cannot be read
- **THEN** the checker exits 1 with a diagnostic identifying the unreadable path
