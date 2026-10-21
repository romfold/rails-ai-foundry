## Purpose

Provide a source-only view of Rails application ownership and dependencies before manually extracting business packages.

## ADDED Requirements

### Requirement: Read-only adoption assessment
`foundry adoption assess --root=PATH --format=text|json` SHALL work with or without a manifest. It SHALL inventory conventional Ruby sources, declarations, resolvable references, and registered package ownership. It SHALL report concrete boundary violations separately from fatal analysis diagnostics and identify unresolved references and analysis limits. It SHALL NOT initialize Rails, evaluate application code or configuration, contact external services, or write application files.

#### Scenario: Assess unmodified Rails code
- **WHEN** an application has no Foundry manifest and its boot files raise if loaded
- **THEN** assessment reports host declarations and dependencies without booting or changing the application

#### Scenario: Incomplete analysis
- **WHEN** source contains invalid syntax, symbolic links, or unsupported structure
- **THEN** assessment reports actionable diagnostics and returns a failing status instead of claiming complete coverage

### Requirement: Explicit ownership choices
Assessment SHALL label namespace/directory groupings as candidates for human review, not business ownership decisions. Installed adoption guidance SHALL cover choosing one context, manual extraction, public entry points, preserving existing tables through explicit mappings, Foundry record inheritance, runtime verification, and rollback. Manifest-v1 migration SHALL remain a separate explicit review.

#### Scenario: Extract one context
- **WHEN** a developer follows the installed adoption workflow
- **THEN** existing generators scaffold the chosen package and guidance requires reviewed code changes and tests without automatic source or data conversion
