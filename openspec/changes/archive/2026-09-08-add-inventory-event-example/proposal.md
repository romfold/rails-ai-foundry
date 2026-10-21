## Why

The event runtime needs a small executable consumer that demonstrates domain rejection, durable replay, upcasting, projections and optimistic concurrency through public generators.

## What Changes

- Add examples/inventory_reservations with its own locked managed Ruby/Rails/PostgreSQL event bundle.
- Generate a v2 event_sourced Inventory package, composition, stock aggregate, event contracts, availability projection and read model.
- Demonstrate restock, reserve and release with rejected invalid quantities/availability/releases and no appended rejected events.
- Add preserving setup, fresh-stream demo, verification, a historical fixture, rebuild and concurrency scenarios; extend CI.

## Capabilities

### New Capabilities
- `inventory-reference-workflow`: Executable local event-sourced inventory example and verification.

### Modified Capabilities
None.

## Impact

A separate Rails host and documentation, CI managed job extension. Core floors/version, the support desk v1 layout and gem packaging remain unchanged. No controllers, UI, payment logic, jobs, external services, publishing or model calls.
