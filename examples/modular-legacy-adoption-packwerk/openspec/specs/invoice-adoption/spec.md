# Invoice adoption specification

## Purpose

Preserve invoice report behavior while moving a legacy endpoint behind an explicit public context API.

## Requirements

### Requirement: Paid invoice reports agree
The legacy and extracted report endpoints SHALL return the same paid total in integer cents, excluding open invoices. Marking an invoice paid repeatedly SHALL preserve one invoice and one paid amount. Missing invoice payment requests SHALL return not found without changing other records.

#### Scenario: Paid and open invoices
- **WHEN** a paid invoice has 1250 cents and an open invoice has 3400 cents
- **THEN** both report endpoints return paid_cents of 1250
- **AND** marking the open invoice paid twice produces a total of 4650 without duplicate invoices

### Requirement: Incremental extraction preserves accepted debt
Normal checks SHALL preserve the reviewed baseline byte-for-byte and reject new source locations referencing private context objects. An explicit disposable extraction SHALL preserve the legacy endpoint response after removing its former implementation and retiring only its resolved debt.

#### Scenario: Another caller of an accepted private constant
- **WHEN** a new source file accesses the private invoice model
- **THEN** Packwerk verification fails and the checked-in accepted baseline remains unchanged

#### Scenario: Extract the endpoint
- **WHEN** the legacy route uses the extracted report controller and the former caller is removed
- **THEN** the same HTTP behavior tests pass and explicit retirement of the resolved debt leaves no new violations

Architectural constraints are defined by config/foundry.yml and the context package.yml/foundry.yml files. These requirements do not duplicate that configuration.
