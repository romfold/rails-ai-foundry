# Tenant-scoped retrieval and evidence answers

Status: implemented and locally verified; see reconciliation.md.

## Behavioral requirements

- Authorized ingestion persists documents and versioned passage embeddings atomically. A failed provider call cannot leave partial passages.
- Repeated tenant/source-key ingestion preserves one document; conflicting content fails. Provider work runs before local persistence transactions. Reembedding rejects a source revision changed during provider work.
- SQL and Neighbor retrieval filter by authenticated tenant, explicit embedding version and current source revision. Deleted documents lose all passages; stale passages cannot answer current requests.
- Answers contain only authorized citation identifiers; missing evidence and unavailable providers cannot produce fabricated success.
- Offline retrieval evaluation includes relevant, irrelevant, and closer cross-tenant documents, with deterministic recall@1 of 1.0 on the checked-in tiny corpus.
- A separate deterministic 240-document evaluation compares exact SQL with an actual HNSW query plan at k=5; it records planner controls, scan limits and recall without claiming production quality or speed.
- Application-owned instrumentation records duration/status and index lag without sensitive request, content or exception payloads.
- Production eager loading uses upstream Rails, packs-rails and optional native RubyLLM without Foundry execution code.

## Acceptance

Run `bin/verify` with the disposable services defined in compose.yml. The tests and reconciliation.md identify evidence; prerequisite checks only establish artifact presence.
