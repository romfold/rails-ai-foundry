## Why

Modular packages need runnable command/query separation and business events while retaining database state as the source of truth. Folder names alone do not establish atomic publication or safe subscriptions.

## What Changes

- Add profile-gated command, query, public event, and event adapter generators.
- Provide immutable versioned event contracts, explicit subscription ownership, and optional Rails Event Store 3.1 integration.
- Install consumer event migrations conservatively and require explicit migration execution.
- Publish and handle local events in the same database transaction as business writes, with rollback on operation failure or handler exceptions.

## Capabilities

### New Capabilities

- `modular-events`: Commands, read-only queries, transactional business events, and reload-safe subscriptions.

### Modified Capabilities

None.

## Impact

Optional consumer dependency and host migrations, component templates, runtime event adapter, tests using a dedicated event bundle, documentation and skills. No distributed delivery, model requests, or example application work.
