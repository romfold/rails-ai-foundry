## Why

Projection rebuild currently materializes all history before decoding. Large stores need bounded batches and query-level type filtering without weakening transactional replay.

## What Changes

- Add an internal enumerator with 1,000-event default batches and event-type filtering before decoding.
- Bound enumeration to history visible at creation and preserve order, atomic rebuild, and existing array-returning APIs.
- Retain full-stream aggregate replay and the aggregate-save reread; add no snapshots or timing-based performance claims.

## Capabilities

### New Capabilities
- `bounded-event-replay`: Bounded, filtered history enumeration for atomic projection rebuild.

### Modified Capabilities
None.

## Impact

Event store history/rebuild internals, SQLite and PostgreSQL regression coverage, and event documentation.
