## Why

The completed pilot shows that passing package checks is not proof of application behavior; it does not establish a broad speed or productivity advantage. The integrated knowledge recipe has a concrete next limitation: retrieval materializes a tenant's documents, rebuilds materialize the catalog, and restart creates a fresh search candidate rather than resuming persisted progress.

## What Changes

- Bound the existing recipe's document/status reads and vector retrieval in the database, preserving authorization, current revisions and exact-search semantics.
- Add application-owned durable rebuild progress, batched backfill, change catch-up, worker fencing, explicit cancellation and safe resume for search and embedding versions.
- Replace full-catalog final-gate work with bounded reconciliation; persist and reconcile ambiguous search-alias cutover outcomes.
- Add operator-visible progress and payload-safe notifications using existing Rails delivery and instrumentation.
- Verify real process interruption, concurrent mutation and resource bounds on disposable services with offline providers. Publish reproducible runtime measurements independently of coding-agent results.
- Package the demonstrated behavioral/recovery testing patterns in references used by existing product skills, with installed-gem replay and valid/invalid implementation controls.

This is proposed work, not an implemented capability. The twelve examples, eight skill identities, independent bundles, Rails/packs/packs-rails/Packwerk foundations and Foundry development-only role remain unchanged. There is no new Foundry execution runtime, CLI wrapper or required provider.

## Capabilities

### New Capabilities

- `bounded-knowledge-operations`: Bounded authorized reads, resumable projection rebuilds, reconciled cutover, operational evidence and reusable application-owned verification guidance.

### Modified Capabilities

None. The existing `integrated-knowledge` guarantees remain in force. The new capability strengthens the advanced recipe with additional operational guarantees rather than replacing its verified baseline.

## Impact

Primary implementation stays in `recipes/domain-knowledge-rag-rom-res-elasticsearch-pgvector`: Knowledge public catalog and persistence, Search services/adapters, root migrations, Rails delivery, offline acceptance and its CI lane. Shared verification references and installed-skill acceptance change only after executable recipe evidence exists. Preserve core schemas, command/report semantics, compatibility floors and existing locks unless a demonstrated incompatibility requires a reviewed update.

Research 13/14 motivate bounded data flow, tenant-safe projections and application-owned observability; their old runtime/configuration proposals remain superseded. The current first-feature tutorial and adoption journey are already delivered and are not repeated. The September 16 trial evidence remains immutable. No additional coding-agent trial, paid provider evaluation, deployment or publication is included. Hosted release CI stays in its existing pending change until a repository destination is provided.
