## Why

A profile needs a runnable application workflow, not only a folder declaration. New use cases need one operation contract and package-owned persistence and dependency wiring.

## What Changes

- Generate profile operations, models, ports, and external adapters with conservative receipts.
- Provide a small operation base, abstract record base, explicit package composition, and reload integration.
- Enforce profile namespaces and layer references statically; preserve legacy operation behavior.

## Capabilities

### New Capabilities

- `profile-runtime`: Operations, persistence ownership, and explicit dependency wiring.

### Modified Capabilities

- `operation-generation`: Profile-aware paths and result contracts while preserving legacy scaffolds.

## Impact

Add dry-operation and dry-system runtime dependencies, optional consumer Active Record, component generators, model migration templates, Railtie prepare integration, tests, and bundled skills. No events or examples in this change.
