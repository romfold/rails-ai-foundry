## Context

Projection currently uses a unique processing receipt and one persistent lock row. Generated migrations already provide the necessary columns and indexes. See proposal.md for the verification gap.

## Goals / Non-Goals

**Goals:** Fail early on incompatible processing schemas; demonstrate synchronization using real PostgreSQL transactions.

**Non-Goals:** Distributed delivery, retries, changed ownership, application database administration.

## Decisions

- Check schema before projection processing/rebuild, rather than at composition registration: db:migrate must still boot before generated tables exist. Inspect actual adapter columns and indexes and require unconditional event_id uniqueness.
- Use a separate pg-enabled event bundle and require FOUNDRY_POSTGRES_TEST_URL with a disposable database name ending in _test. Each test owns a random schema, removes only that schema, and uses independent pooled connections with queue barriers.
- Keep SQLite tests and transaction boundaries. Record concrete PostgreSQL, pg, Ruby, Rails and event-store versions.

## Risks / Trade-offs

Schema inspection adds small per-operation catalog work; avoiding a stale cache keeps migrations and altered constraints observable. Concurrency tests use bounded waits and explicit barriers, not elapsed-time claims. PostgreSQL fixtures are isolated schemas but still require an explicitly disposable database.

## Migration Plan

Existing generated migrations need no changes. Repair missing constraints through consuming application migrations before processing. Local tests start a separate temporary PostgreSQL 17 cluster and never use an existing service.
