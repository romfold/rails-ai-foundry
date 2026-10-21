## MODIFIED Requirements

### Requirement: Native generation stays independent of legacy installation
Native context and component generators SHALL NOT load application execution code. Shared filesystem safety utilities MAY be reused. Unsupported generator names SHALL fail without writing files.

#### Scenario: Native delivery entrypoints
- **WHEN** a consumer generates a controller, job, mailer or channel with `--context=NAME`
- **THEN** Rails discovers the generator and creates the pack-owned class inheriting the corresponding application shell base class without initializing the application
- **AND** implemented controller routes, views and jobs execute using ordinary Rails integration

#### Scenario: Legacy setup in a native application
- **WHEN** root config/foundry.yml exists and the user invokes foundry:install or foundry:setup
- **THEN** Rails reports that the generator is unavailable and does not modify files; the migration guide identifies standalone workflow setup and context generation as replacements

#### Scenario: Independent native generator loading
- **WHEN** an installed consumer invokes native operation, command, model or query generation
- **THEN** the generator completes without loading application execution code
