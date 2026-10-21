## Context

The completed event runtime provides generators, composition, owned contracts, aggregate repositories, projections, upcasters and bounded rebuild. The support desk is a separate v1 consumer.

## Goals / Non-Goals

**Goals:** A minimal Rails runner/test host that makes event-sourced domain behavior executable without UI concerns.

**Non-Goals:** Controllers, browser UI, payments, background jobs, external network operations, aggregate snapshots, deployment and publishing.

## Decisions

- Pin Ruby 3.4.10, Rails 8.1.3.1, Rails Event Store 3.1.0 and pg 1.6.3 with the local Foundry checkout. Require PostgreSQL 17 and explicit local connection configuration. Keep the application bundle separate from framework support floors.
- Generate Inventory with event_sourced profile, stock aggregate, restocked/reserved/released domain events, availability read model/projection and composition. Application migrations add required unique item identity and numeric constraints.
- Each stock stream owns one item identifier. Restock/reserve/release validate before recording; projection uses injected owned read models. Composition exposes the aggregate repository and registers projection/upcasters.
- Restocked v1 uses units; v2 uses quantity. A committed fixture is inserted into a new fixture stream by the example verification harness only, then read via the real Foundry runtime. It never updates old rows.
- Setup uses db:prepare; demo uses fresh UUID-derived item/stream identifiers and deterministic state assertions. Verification uses an explicitly disposable test database and checks repeated setup preservation in a subprocess.
- Extend the managed CI job with separate inventory test database and its own bundle. Keep application files excluded by the existing gem allowlist.

## Risks / Trade-offs

The synchronous demo and projection rebuild target a local single-process reference. Runtime guarantees come from database transactions and optimistic concurrency, not retries or distributed delivery. Verification may rebuild the example's read models and therefore runs in a separate test database; setup never resets events.
