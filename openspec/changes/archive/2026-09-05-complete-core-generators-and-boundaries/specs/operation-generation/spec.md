## Purpose

Give consuming applications a repeatable plain Ruby operation scaffold owned by a registered package.

## ADDED Requirements

### Requirement: Package-owned operations

`foundry:operation NAME --package=PACKAGE` SHALL accept snake_case names and a registered domain or platform package. It SHALL generate a namespaced Ruby object with `#call`, a package-local executable test, and a generation receipt. Operations SHALL be private by default under `app/operations`; `--public` SHALL place the operation under `app/public`. The generated call SHALL raise `NotImplementedError` until application behavior is implemented, and the generated test SHALL verify that scaffold contract.

#### Scenario: Generate and execute both package types
- **WHEN** private and public operations are generated in domain and platform packages
- **THEN** their tests execute in an opted-in Rails host and their constants follow the existing package namespace conventions

### Requirement: Conservative operation generation

Generation SHALL preserve customized complete scaffolds on repeat, reject partial or conflicting scaffolds and visibility changes, reject unsafe paths and invalid names before writing, support a non-writing pretend mode, and roll back only unchanged files created by the failed invocation.

#### Scenario: Preserve edited operation
- **WHEN** a complete generated operation and test have been edited and generation repeats with the same options
- **THEN** their contents remain unchanged

#### Scenario: Reject unsafe or partial output
- **WHEN** a destination is a symlink or only part of a scaffold exists
- **THEN** generation fails without modifying existing files

#### Scenario: Failed write
- **WHEN** writing the scaffold fails after creating one file
- **THEN** unchanged new files are removed and user changes are preserved
