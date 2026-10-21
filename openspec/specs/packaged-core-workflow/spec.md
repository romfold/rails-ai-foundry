# packaged-core-workflow Specification

## Purpose
Prove the complete non-AI Foundry workflow uses the installed gem archive and its bundled resources.

## Requirements

### Requirement: Independent installed-archive acceptance

An automated local acceptance task SHALL build the gem, install it into a temporary gem home, and run a fresh minimal Rails host with its own bundle and no source-path reference to Foundry. It SHALL verify the loaded Foundry path belongs to the installed archive, safe repeated installation/generation, skill availability, operation execution, package loading, and static boundary success/failure. The task SHALL use already installed dependencies and SHALL NOT require external requests, credentials, example code, or publication.

#### Scenario: Complete core workflow
- **WHEN** the archive acceptance task runs with its dependencies installed
- **THEN** it sets up the selected workflow and skills, generates native contexts and operations, implements and tests a deterministic public operation, checks allowed references, and rejects private/undeclared references

### Requirement: Complete distributable resources

The archive SHALL contain development-time code, all generator templates, the Foundry catalog, core workflow documentation, and the exact MIT license. It SHALL exclude tests, development-only OpenSpec skills, example applications, credentials, and research originals.

#### Scenario: Inspect the archive
- **WHEN** archive contents are inspected
- **THEN** all workflow resources are present and development/example content is absent

### Requirement: Replayed first-feature tutorial
The installed archive SHALL include a first-feature tutorial with two Rails-native contexts, public lookup, declared dependency, persistent validated invoices and pack-owned delivery. Archive acceptance SHALL replay its executable snippets, prove persistence across processes, reject a deliberate private access and verify the repair. Tooling and data SHALL remain offline in a disposable SQLite consumer.

#### Scenario: Follow distributable instructions
- **WHEN** archive acceptance replays the shipped tutorial
- **THEN** its commands and files create working behavior without the Foundry source checkout
- **AND** restart, validation, loading, boundary failure and repair are independently asserted

### Requirement: Intentional distributable documentation
The archive SHALL select documentation through an explicit resource list, include required local link targets and exclude research drafts, local plans, secrets, tests and example applications. Contributor checks SHALL report suspected privacy findings by location and category without exposing values.

#### Scenario: Contaminated source tree
- **WHEN** an archive is built with arbitrary local documents and synthetic sensitive files present
- **THEN** the installed resource inventory remains unchanged and required local documentation links resolve

#### Scenario: Privacy finding
- **WHEN** contributor scanning encounters a personal workstation path or supported credential signature
- **THEN** it fails with a location/category diagnostic and does not print the matched value
