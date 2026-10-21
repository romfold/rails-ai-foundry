# legacy-adoption-flagship Specification

## Purpose

Reproduce incremental Rails extraction while retaining behavior and accepted upstream boundary debt.

## Requirements

### Requirement: Executable adoption application
The application SHALL have an independent bundle, a modular focal context, ordinary Rails delivery and application-local OpenSpec artifacts. It SHALL demonstrate an existing internal dependency alongside a public API replacement without a Foundry execution runtime.

#### Scenario: Behavior parity
- **WHEN** the legacy report and extracted public API read the same invoices
- **THEN** they return the same paid total, excluding unpaid invoices

### Requirement: No new debt and reviewed retirement
Verification SHALL preserve checked-in accepted debt and reject a new source location referencing the same internal constant. A disposable-copy extraction SHALL demonstrate public API parity and explicitly retire only the resolved debt. Normal checks SHALL NOT regenerate baselines.

#### Scenario: New reference to an accepted constant
- **WHEN** a second legacy caller is introduced in a disposable copy
- **THEN** verification fails while the original accepted baseline remains byte-identical
