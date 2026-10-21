## Purpose

Make incremental extraction of existing Rails delivery reproducible from installed guidance, with explicit behavioral and loading evidence.

## ADDED Requirements

### Requirement: Installed extraction guidance preserves behavior
The installed guide SHALL describe staged extraction preserving routes, authorization, rendering, browser interactions and persisted records while retaining shell model/table ownership. It SHALL provide observable checkpoint acceptance and reversible rollback without requiring a Foundry checkout.

#### Scenario: Default and custom roots
- **WHEN** the installed guide is replayed with default or established custom package roots
- **THEN** both the starting and extracted applications pass equivalent HTTP/browser behavior and the extracted application loads without Foundry production dependencies

### Requirement: Evidence detects extraction faults
Acceptance SHALL distinguish loading, structural, boundary and behavioral results, and reject deliberate route, rendering, asset, authorization, omitted-test and private-access faults after a healthy baseline. Equivalent valid wiring SHALL remain acceptable.

#### Scenario: Assets missing
- **WHEN** extraction removes required feature JavaScript wiring
- **THEN** browser behavior fails even if structural checks pass

#### Scenario: Broken framework baseline
- **WHEN** the application's framework tests cannot execute
- **THEN** separate browser observations do not satisfy that incomplete acceptance requirement

### Requirement: Guidance preserves application ownership
Updated guidance SHALL remain within the existing eight skills and support reviewed delivery without overwriting customized skills, project instructions, workflow selection, receipts or accepted debt outside the explicit upgrade decisions.

#### Scenario: Customized installed guidance
- **WHEN** a consumer upgrades the installed guidance with local changes
- **THEN** it requires explicit conflict decisions, preserves unrelated application state, and executes verification after upgrade
