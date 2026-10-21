## Purpose

Allow applications to explicitly enable standard Rails loading behavior for Ruby code in their declared packages without changing structural-check semantics.

## ADDED Requirements

### Requirement: Explicit activation preserves existing behavior

Package loading SHALL default to disabled and activate only through `config.rails_ai_foundry.autoload_packages = true`. Enabled applications SHALL validate package structure before registering loading paths and fail initialization with actionable diagnostics for invalid or missing configuration.

#### Scenario: Existing application does not opt in

- **WHEN** an application loads Foundry without enabling package loading
- **THEN** Foundry does not add package loading paths or reject application boot because of the manifest

#### Scenario: Enabled application has invalid configuration

- **WHEN** an enabled application initializes with a missing or structurally invalid manifest or package
- **THEN** initialization fails with the reported configuration or structural problem

### Requirement: Package code follows Rails loading lifecycle

Enabled applications SHALL load declared package Ruby through Rails-managed lazy loading, development reloading, and production eager loading. Immediate package app subdirectories SHALL act as Ruby roots except assets and views. Existing canonical public namespace paths SHALL remain usable. Nested files SHALL follow ordinary filename-to-constant conventions.

#### Scenario: Lazily load domain and platform code

- **WHEN** an enabled application references Billing, Platform::Messaging, or Billing::CreateInvoice in their conventional public or services paths
- **THEN** their Ruby code loads without application-authored require calls

#### Scenario: Reload changed code

- **WHEN** development reload runs after a loaded package class changes
- **THEN** subsequent constant access observes the changed code

#### Scenario: Eager loading and naming errors

- **WHEN** production eager loading initializes valid package code
- **THEN** package Ruby is loaded
- **AND** incorrectly named constants produce visible loader errors rather than being swallowed

#### Scenario: Non-Ruby roots and registry changes

- **WHEN** a package contains assets or views, or its registration changes after boot
- **THEN** assets and views are not registered as Ruby roots
- **AND** application restart is required to register a changed package list

### Requirement: Structural checking remains independent of application boot

The structural-check command MUST remain read-only and MUST NOT initialize the application or load package Ruby even when package loading is enabled. Runtime loading success MUST NOT be presented as privacy or dependency enforcement.

#### Scenario: Check an enabled application without booting it

- **WHEN** the structural task runs in an opted-in host with an initializer and package code that would raise if executed
- **THEN** it reports structural results without executing either
