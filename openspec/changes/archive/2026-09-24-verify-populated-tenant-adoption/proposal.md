## Why

The existing adoption journey preserves ownership already present in documents. It does not demonstrate introducing that ownership safely in populated tables while writes continue.

## What Changes

Add a separate application-owned tenant-backfill scenario with extraction first, resumable batches, validated constraints, bounded cutover and compatible rollback. Preserve the original recipe replay.

## Capabilities

### New Capabilities
- `populated-tenant-adoption`: Populated tenant adoption.

### Modified Capabilities
None.

## Impact

Existing skills, installed acceptance, explicit packaging and documentation. No new Foundry runtime, configuration, catalog application, agent trial or publication. Final verification uses the existing release-candidate change.
