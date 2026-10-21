## Purpose

Detect static cross-package constant dependency and privacy violations in consuming Rails applications.

## ADDED Requirements

### Requirement: Separate boundary validation

`foundry:architecture:boundaries` SHALL first validate structure and then check static constant references in application `app/` and registered package `app/` Ruby files. It SHALL return status 0 for valid references and status 1 with source locations and corrective diagnostics for undeclared dependencies, cross-package private references, invalid Ruby syntax, or invalid enforcement configuration. It SHALL allow a package to reference its own internals and allow host application code to reference public package contracts. Package code SHALL NOT depend on host application constants. It SHALL use conventional Rails autoload roots without initializing Rails or evaluating package code. Existing structural check behavior SHALL remain unchanged.

#### Scenario: Declared public access
- **WHEN** a package references a public constant in a declared dependency
- **THEN** the boundary check succeeds

#### Scenario: Undeclared dependency or private access
- **WHEN** a package references an undeclared package or a private constant in another package
- **THEN** the boundary check fails and identifies the reference and violated boundary

#### Scenario: Static checks stay offline
- **WHEN** package Ruby and Rails initialization would raise if executed
- **THEN** checking reads source without running that code or changing application files

### Requirement: Explicit enforcement without baselines

New packages SHALL include privacy enforcement with `app/public` as the public path. The boundary command SHALL reject absent or disabled privacy, custom public paths, bypass metadata, and package TODO baselines. Existing packages SHALL receive actionable migration diagnostics without automatic metadata rewrites. Boundary checks SHALL reject symbolic links in inspected application source trees.

#### Scenario: Existing package migration
- **WHEN** existing metadata lacks privacy enforcement
- **THEN** structural validation still succeeds and boundary validation names the fields needed to enable privacy

#### Scenario: No ignored violations
- **WHEN** a package TODO file or privacy bypass is present
- **THEN** boundary validation fails instead of accepting a baseline
