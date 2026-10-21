## Purpose

Compose the installed framework into a normal Rails application without prescribing unrelated application capabilities.

## ADDED Requirements

### Requirement: Local application template
`foundry template` SHALL print the bundled Rails application template path. The template SHALL pin the matching gem version and run setup after bundling, support locally installed archives, and preserve Rails-selected stack options without applying migrations or adding optional capabilities.

#### Scenario: Create an application offline
- **WHEN** Rails creates an application using the installed template with dependencies available locally
- **THEN** the application contains Foundry setup and loads framework code from the installed archive

### Requirement: Conservative complete setup
`foundry:setup` SHALL install the foundation, selected agents or claude skills, and early explicit package loading. Fresh setup SHALL use an empty version-2 manifest. Pretend mode SHALL not write. Repeats SHALL preserve edited artifacts, and unsupported configuration, conflicting skills, unsafe paths, and incompatible manifests SHALL fail before changes. Ordinary installation SHALL retain its existing behavior.

#### Scenario: Repeat customized setup
- **WHEN** setup is repeated after editing installed guidance and skills
- **THEN** edits are preserved and package loading is not duplicated

#### Scenario: Configuration conflict
- **WHEN** application loading configuration is conflicting or unsupported
- **THEN** setup fails with corrective guidance without partially installing resources

#### Scenario: Failure during writes
- **WHEN** setup encounters a filesystem failure
- **THEN** it cleans up only unchanged artifacts created by that invocation and preserves concurrent user edits
