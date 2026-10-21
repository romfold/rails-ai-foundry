# native-rails-checks Specification

## Purpose
Provide verified native rails checks for Rails consumers while keeping Foundry a development-time conventions kit.

## Requirements

### Requirement: Native Rails checks use application configuration
All consuming applications SHALL route Rails Rake checks to the native configuration assessment. Default checking SHALL remain boot-free. Explicit boundary verification SHALL invoke the consuming bundle's Packwerk in test and propagate failure. Legacy Rake task routing SHALL NOT remain.

#### Scenario: Native structural checking
- **WHEN** a configured native application runs `foundry:check`, `foundry:architecture:check`, or `foundry:architecture:conventions` through Rails
- **THEN** the task validates configuration without initializing Rails or executing package code
- **AND** reports that Packwerk boundaries have not been checked

#### Scenario: Invalid or mixed configuration
- **WHEN** native root configuration is invalid or a legacy architecture manifest remains
- **THEN** native Rails checking fails with actionable configuration or migration guidance without writing files

#### Scenario: Explicit upstream boundaries
- **WHEN** a native application runs `foundry:architecture:boundaries`
- **THEN** upstream verification requires its installed locked bundle and Packwerk configuration
- **AND** accepted debt remains unchanged and a new violation produces a failing exit status

### Requirement: Native startup avoids the legacy loader
Rails integration SHALL provide development-time tasks without a Foundry package loader or execution runtime. Application loading SHALL use packs-rails.

#### Scenario: Ordinary native loading
- **WHEN** an installed-gem native consumer boots and eager loads through packs-rails without a Foundry loader
- **THEN** its generated operation executes without defining Foundry's legacy PackageLoading or Runtime constants

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
