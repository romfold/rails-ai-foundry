## Why

Business event publication now works, but the event_sourced profile lacks authoritative aggregate persistence and safe read-model replay. Deliver these separately so storing events cannot be confused with a completed event-sourcing workflow.

## What Changes

- Add pure Ruby aggregate replay and package-owned optimistic stream persistence.
- Generate projection handlers, processing migrations, and read models.
- Persist idempotency records and rebuild only a named projection's owned read models without republishing events.

## Capabilities

### New Capabilities
- `event-sourced-runtime`: Ordered aggregate replay, concurrency checks, persistent projection processing, and scoped rebuild.

### Modified Capabilities

None.

## Impact

Optional event runtime, domain aggregate support, profile-gated generators, host migrations, package composition registration, and delivery tests. No distributed processing or automatic data conversion.
