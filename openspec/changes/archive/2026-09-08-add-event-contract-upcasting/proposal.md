## Why

Stored events currently decode only at the current registered contract version. Applications need explicit, testable evolution of historical payloads without modifying authoritative records or widening class construction.

## What Changes

- Add Composition.event_upcasters with an empty default and application-owned Events::Upcaster declarations.
- Validate package ownership and consecutive positive-version chains ending at the one current contract per TYPE.
- Decode historical data through registered transformations; encode only current contracts and preserve stored records and envelope identity/metadata.
- Reject incomplete or ambiguous chains and malformed transformation output with sanitized ContractError diagnostics.
- Add committed historical fixtures, mixed-version replay and rebuild-rollback coverage, and an ADR requiring deterministic transformations without IO.

## Capabilities

### New Capabilities

- `event-contract-upcasting`: explicit read-time historical payload evolution and chain validation.

### Modified Capabilities

- `modular-events`: registered version support includes explicit complete upcaster chains while unknown or unsupported versions still fail.

## Impact

Optional event composition, contract registry and codec; historical fixture tests and event guidance. No dependency, manifest, stored-event, public TYPE, event ID, stream position, or ordering changes. Publishing, history rewriting and snapshots remain excluded.
