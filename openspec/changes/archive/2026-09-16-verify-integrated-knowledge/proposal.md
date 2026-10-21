## Why

Separate recipes do not establish that ROM, Rails Event Store, Elasticsearch, RubyLLM and pgvector work together. A tenant-scoped knowledge application will make the transaction, authorization and recovery boundaries executable.

## What Changes

- Add an independently bundled Rails recipe with Access, Knowledge, Search and Answering packs, native delivery and a working offline UI.
- Verify atomic ROM writes and outbox intent, post-commit RES publication, durable independent projection delivery and recovery.
- Verify revision-aware Elasticsearch and vector projections, safe rebuilds, authorized retrieval and citations.
- Add independent offline acceptance, Spec Kit artifacts and compatibility evidence.

## Capabilities

### New Capabilities
- `integrated-knowledge`: Complete knowledge application composition and failure recovery.

### Modified Capabilities

None. Existing standalone recipes and the twelve-example catalog remain intact.

## Impact

New advanced recipe, disposable PostgreSQL/Elasticsearch services, independent lockfiles and CI. No Foundry execution runtime, new configuration schema or mandatory application dependency. Guided adoption and skill benchmarks are subsequent coordinated changes.
