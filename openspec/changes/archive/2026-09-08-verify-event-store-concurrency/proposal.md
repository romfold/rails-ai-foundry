## Why

SQLite does not demonstrate PostgreSQL row-lock behavior. Projection idempotency also depends on database constraints that an application can accidentally omit.

## What Changes

- Validate non-null event_id and an unconditional, single-column unique index before projection processing.
- Add an explicitly configured disposable PostgreSQL 17 lane using independent connections and synchronization barriers.
- Preserve synchronous handlers, SQLite coverage, ownership, and existing conflict behavior without automatic retries.

## Capabilities

### New Capabilities
- `event-store-concurrency`: Processing schema validation and PostgreSQL transactional concurrency verification.

### Modified Capabilities
None.

## Impact

Projection processing, separate PostgreSQL test bundle and host, compatibility documentation. The database must be explicitly disposable; no existing application database is used.
