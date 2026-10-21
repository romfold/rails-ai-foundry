## MODIFIED Requirements

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
