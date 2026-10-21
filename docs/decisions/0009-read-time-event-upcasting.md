# 0009: Read-time event contract upcasting

Date: 2026-09-08
Status: Accepted

## Context

A single current contract per event type keeps publication explicit, but persisted historical payloads need an application-owned migration path when that contract evolves. Updating stored history would change the audit record.

## Decision

Compositions declare consecutive `Events::Upcaster` transitions for their own event types. Reads transform isolated payload copies and construct the current immutable contract. Writes accept only the current contract. The store never rewrites records during upcasting; identifiers, metadata, stream positions, and order remain unchanged. Missing chains fail closed. Transformation errors expose the type and transition, without payloads or exception causes.

Every supported transition requires committed historical fixtures. Transformations must be deterministic and perform no IO. Static checks cannot prove historical compatibility or transformation purity. Projection rebuild retains its existing transaction and rollback behavior.

## Consequences

Deploy the current contract and complete supported chains together. Retain required transitions as long as historical records need them. A source rollback must still read newly published versions. There is no automatic downcast, event rewrite, snapshot mechanism, or additional retry loop.
