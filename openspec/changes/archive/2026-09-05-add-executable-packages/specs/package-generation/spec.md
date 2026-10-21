## Purpose

Create minimal executable domain and platform packages while preserving existing application content and authoritative package registration.

## ADDED Requirements

### Requirement: Generate and register a minimal package

`bin/rails generate foundry:package NAME` SHALL accept `--type domain|platform` and an explicit dependency list, defaulting to domain and no dependencies. It SHALL require structurally valid installed configuration and apply the existing identifier and dependency rules. Successful generation SHALL create canonical package metadata, a public namespace module, and a package-local Minitest skeleton, then register the package.

#### Scenario: Generate domain and platform packages

- **WHEN** a user generates platform messaging followed by domain billing depending on messaging
- **THEN** their canonical public modules and metadata are created, both registry entries exist, and structural validation succeeds
- **AND** their generated tests run in a Rails application with package loading enabled

#### Scenario: Reject invalid requests

- **WHEN** configuration is missing or invalid, or a request has an invalid identifier, type, or dependency
- **THEN** generation exits unsuccessfully with an actionable diagnostic and writes no files

### Requirement: Preserve existing content and reject conflicts

An exact repeated request SHALL preserve package content and manifest bytes. Conflicting declarations, existing unregistered destinations, partial generated packages, symbolic links, and incompatible destination types MUST fail without overwrites. Force MUST NOT bypass these rules. Pretend SHALL perform validation without writes; automatic reversal SHALL fail without removing files.

#### Scenario: Repeat a customized package

- **WHEN** generation repeats the same type and dependency set for a complete package whose public module or test was customized
- **THEN** it reports existing artifacts and changes no content

#### Scenario: Conflict or partial installation

- **WHEN** a declaration differs or a destination exists without a complete matching registration and generated file set
- **THEN** generation fails and preserves existing content even with force

#### Scenario: Preview or reversal

- **WHEN** the user requests pretend generation or automatic reversal
- **THEN** no files are changed
- **AND** pretend validates and reports planned artifacts while reversal reports that manual review is required

### Requirement: Publish registration conservatively

Adding a package SHALL preserve validated manifest data while normalizing YAML formatting and comments. It SHALL preserve manifest permissions and publish registration only after package files are written. Changed source manifests MUST be detected before replacement. On failure, existing or concurrently changed content MUST be preserved; cleanup SHALL remove only unchanged artifacts created by the failed invocation and report leftovers.

#### Scenario: Normalize a commented manifest

- **WHEN** generation adds a package to a valid commented manifest
- **THEN** existing registry data and file permissions are preserved while formatting and comments may be replaced

#### Scenario: Failed writes or concurrent edits

- **WHEN** writing fails or another writer changes the source manifest before replacement
- **THEN** generation fails without replacing the existing or concurrently edited manifest
- **AND** unchanged newly generated artifacts are removed when possible
