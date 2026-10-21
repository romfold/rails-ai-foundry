## Purpose

Make profiled packages executable through consistent operations, owned persistence, and explicit dependency composition.

## ADDED Requirements

### Requirement: Profile components are generated conservatively

Foundry SHALL generate operations, models, ports, and external adapters in the profile registry's canonical locations with package-local tests and receipts. It SHALL reject unsupported components, unsafe names, conflicting output, and partial repeats before writes. Models SHALL use package-prefixed tables and host migrations and inherit an abstract Foundry record base.

#### Scenario: Model generation

- **WHEN** a light package generates an invoice model
- **THEN** its model and host migration use the package-owned table and preserve edits on repeats

#### Scenario: Unsupported model

- **WHEN** a full-domain package requests a light model
- **THEN** generation fails before writes and describes the supported profile components

### Requirement: Explicit application result and dependency contract

Profile operations SHALL receive dependencies through explicit constructors and return success or failure results. Package composition SHALL assemble dependencies and refresh after Rails reload. Public entry points SHALL invoke their package's application behavior through explicit wiring. Loading the core gem alone SHALL not require Active Record or initialize Rails.

#### Scenario: Replace a dependency in tests

- **WHEN** an operation receives a fake dependency through its constructor
- **THEN** its success and failure paths run without resolving a global container

#### Scenario: Reload composition

- **WHEN** Rails reloads a changed package component
- **THEN** the rebuilt composition uses the new class rather than a stale instance

### Requirement: Profile runtime is available from the archive

The built gem SHALL include component templates, runtime helpers, and skill references needed for install, generate, implement, and check in a minimal Rails host without example code or external services.

#### Scenario: Installed workflow

- **WHEN** a fresh host installs the archive and implements a generated MVP operation backed by an owned model
- **THEN** its behavior tests and architecture checks pass using the installed gem
