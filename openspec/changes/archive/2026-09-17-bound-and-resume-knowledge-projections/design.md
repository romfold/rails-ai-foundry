## Context

See proposal.md for motivation. Observed implementation, not inferred shortcomings:

| Existing source in the integrated recipe | Observed behavior | Proposed change |
| --- | --- | --- |
| Knowledge::Catalog#list, #visible, #snapshots | Unbounded `.all` calls | Keyset pages and bounded candidate revalidation |
| Knowledge::Catalog#delivery_status | Loads all tenant IDs and all queue status before Ruby filtering | Query statuses only for the authorized document page |
| Search::Service#retrieve_current / VectorIndex#ranked | Loads visible documents and ranked vectors before taking five | Tenant/version SQL filtering and bounded candidate retrieval |
| Search::Service#rebuild_search / #cutover_search | In-memory catalog scans; fresh random candidate on retry; full final scan under writer gate | Persisted candidate/checkpoints and bounded catch-up |
| Search::Service#rebuild_vectors | Full scans and in-memory completeness comparison | Resumable batches and persisted validation evidence |
| ElasticIndex#upsert / #validate! | Refreshes individual writes; fetches each expected document | Bounded bulk writes and paged validation |
| Knowledge::Database#gate | Transaction-scoped advisory writer gate | Retain it as the explicit sequencing/cutover boundary |

Existing real-service tests already cover many revisions, leases, rollbacks and failure cases. This work adds scale and process-resume guarantees; it does not describe the current recipe as unverified. Demo authentication stays explicitly a demo.

Research 13/14 support efficient Rails-native data flow, independent profiles/capabilities, tenant isolation and upstream instrumentation. PLAN 7's first-feature replay is delivered. The Cursor architecture-plan scoring/runtime proposal is superseded. The pilot's six Foundry successes justify no blanket skill rewrite; its false negatives show why acceptance must allow equivalent implementations.

## Goals / Non-Goals

**Goals:** Extend the existing application without changing Foundry's execution model. Make resource limits, recovery state and correctness observable. Teach these patterns through executable references.

**Non-Goals:** New capabilities/providers, ANN tuning, replicas/sharding, a universal projector/telemetry/verification runtime, production identity, a thirteenth catalog example, new Foundry commands/schema keys, or additional agent trials. Do not propagate the advanced stack into basic adoption. Hosted CI and publication retain their separate gate.

## Decisions

### 1. Bound reads without weakening authorization

Keep exact pgvector distance ordering with a deterministic ID tie-breaker. Query Search-owned vectors with tenant and active-version predicates and a database LIMIT. Revalidate only those IDs through Knowledge's public catalog; do not let Search query Knowledge's private tables. Refill stale candidates using a bounded distance/ID cursor. Authoritative revisions, publication and tenant membership are checked again before citations are returned. Return an application-owned result containing documents and an incomplete flag; update the recipe's controllers/tools/tests together. This changes only recipe-local calls, not Foundry public contracts.

Default budgets: document pages 50 (maximum 100); retrieval five results, at most 100 candidate rows across refill; rebuild pages at most 250 rows and bulk requests at most 1 MiB. Bound associated status rows and aggregate counts in SQL rather than materializing delivery history. Inspect oversized source records before loading bodies; a row exceeding the configured payload limit fails explicitly, never disappears silently. Keep limits in application configuration, outside schema-1 foundry.yml.

A SQL LIMIT bounds Ruby materialization, not database work. Measure plans, query counts, allocations and latency; retain query timeouts. ANN, automatic caching and sharding would change behavior/complexity and are deferred.

### 2. Persist application-owned progress and mutation history

Add root migrations for a Knowledge-owned projection-change journal and Search-owned rebuild runs/manifests. Journal identifiers, revision and lifecycle metadata in the same ROM gateway transaction as every business mutation/outbox write. Allocate ordering only while holding the existing transaction-scoped writer gate. Read committed fences under that gate; do not use an unconstrained sequence/MAX(id) as a commit-order guarantee. Rollback gaps are harmless, but delayed lower-sequence commits must be impossible and tested.

Expose paged snapshots, journal pages and fences through Knowledge's trusted public projection API. Journal retention is conservative: no automatic pruning in this scope. Missing history blocks activation. This adds projection maintenance evidence, not authoritative event sourcing or another message broker.

Runs persist destination, candidate identity, embedding version, initial fence, finite scan upper bound, last page key, applied change cursor, validation progress, lease owner/token, attempts, phase and safe error classification. Keep expected per-document revision/status/content digest in a disk-backed manifest, not a Ruby corpus-sized hash. One live run per destination; claims and checkpoints use conditional updates and fencing tokens. Phases are queued, backfilling, catching_up, validating, ready, cutting_over, reconciling, completed, failed and cancelled. Solid Queue schedules bounded units; persisted pending runs survive a lost wake-up. Unknown options/version changes on resume are rejected.

### 3. Resume backfill and prove completeness

Register the initial fence and scan bound while holding the writer gate. Keyset-scan the finite ID range, including tombstones. Changes after registration cover inserts behind the cursor, edits, withdrawals and deletion. Persist progress only after the whole destination batch is acknowledged; retry uncertain writes to the same candidate. External versioning prevents stale Elasticsearch effects. PostgreSQL vector writes and progress use short transactions, with provider calls outside them and current revision rechecks afterward.

Lease expiry protects progress, but a database lease alone cannot fence an in-flight external request. Use deterministic candidate IDs, document versions and guarded cutover; stale responses cannot authorize progress. Embedding retries may recompute a batch, so promise safe state, not exactly-once provider invocation. Cancellation stops new units and leaves a reconciliation state if cutover may already have happened.

Validate candidate identity/content against the persisted manifest in bounded pages. Use bulk/multi-get or PIT plus search_after where a complete Elasticsearch scan is needed; close PITs and restart validation safely if a PIT expires. Counts alone are insufficient. Seal validated progress and then replay the remaining journal into both candidate and manifest. Validate changed entries and total membership before selection. No full-corpus scan occurs inside the final writer pause.

### 4. Bounded activation and ambiguous outcomes

Retain the existing ten-second checked gate budget, two-second SQL/lock limits and bounded Elasticsearch request timeouts. Document the maximum in-flight timeout overshoot; do not call this a strict ten-second wall-clock guarantee. Cap final catch-up at one configured batch. If it exceeds that cap or validation is incomplete, release the gate and continue catch-up without swapping. No embeddings or other provider calls run under the gate. Vector activation is a short atomic database change after validated progress reaches the final fence.

Persist search cutover intent before the external alias request: run/candidate, expected prior alias and ownership generation. Under the gate, recheck ownership and the final fence. Use one guarded remove/add alias request, with all-or-nothing failure semantics verified against pinned Elasticsearch 9.3.0. Inspect per-action errors as well as acknowledgment. A stale worker must not be able to replace a newer alias; test expected-prior alias removal with must_exist rather than trusting a local lease.

A timeout after submission is an unknown outcome. Block competing cutover/cleanup, inspect the alias and reconcile: candidate selected means finish local acknowledgment; prior alias still selected permits a guarded retry after ownership validation; an unexpected/multiple target requires explicit repair. Freeze the candidate once cutover intent is persisted: a replacement worker may reconcile it but must not mutate, delete or abandon it while an old request could still take effect. Guard all competing activation paths, including cleanup and cancellation. Journal changes committed after the cutover fence remain replayable; reconcile those into the actual active candidate before reporting the run complete. This preserves recoverable eventual consistency, not a cross-system atomic transaction. Never blindly swap back or claim the alias stayed unchanged. Kill workers before/after external mutation and before local acknowledgment to verify this path. Normal publication continues through the actual active destination, and authoritative visibility checks remain in place.

### 5. Operator guidance and bounded evidence

Use application-owned Rake tasks for start/status/resume/cancel/cleanup, with run IDs and dry-run cleanup. Keep mutations operator-only; do not grant corpus-wide maintenance to tenant demo tokens. Existing tenant UI can show tenant-scoped indexing state. A trusted operator can inspect rebuild counters, lag, last checkpoint, lease/retry state and reconciliation instructions. Reuse ApplicationTelemetry/ActiveSupport notifications; exclude bodies, prompts, credentials and exception text. No APM/exporter dependency is required.

Add process-level acceptance with explicit synchronization points, not timing sleeps. Include crashes after destination write, expired ownership, delayed stale workers, partial bulk failure, lost scheduling, concurrent edits/deletes and uncertain alias acknowledgment. Test valid direct/delegated/relocated entrypoints and deliberate faults separately from Packwerk. Same-pack Rails delivery may use internal models when its chosen contract allows it; the pilot's catalog boundary is not a universal Rails ban.

Run deterministic fixtures with 1,000 and 10,000 documents, three skewed tenants and 1,536-dimensional vectors. CI uses a smaller dataset spanning at least three pages; the local scale lane uses both sizes and fresh processes. Capture maximum fetched rows/bytes, query counts, peak RSS, allocations, p50/p95 request latency, batch throughput, gate duration and recovery time. Warm up, take five retrieval samples per size, and run one full rebuild/recovery sequence per size. Preserve seeds, locks, image IDs, host conditions and commands. Cap each scale scenario at ten minutes and total measurement at thirty minutes; retain timeouts as outcomes. Compare the old and new implementations under matching offline conditions where feasible, recording old failures/timeouts without removing correctness checks. Hard gates concern bounds and correctness, not hardware-dependent speed ratios.

After recipe acceptance, add a small shared behavioral/recovery reference loaded by the existing verify, add-feature, event-workflow and adoption skills as applicable. Replay it against the installed gem with default/custom roots and established workflow preservation. Reuse the first-feature/adoption harnesses rather than creating another app. Retain eight skill identities, receipts and customized-file protection. Keep six-task benchmark v1 and all measured results unchanged; a larger agent study remains a separately authorized follow-up.

## Risks / Trade-offs

### Verified implementation choices

The application stores expected document content in paged database manifests and float32
embedding digests for vector validation. Multi-get plus membership counts avoids a PIT
lifecycle. Quarantine is a flag and retry counter on the current phase, preserving the
checkpoint that failed rather than replacing it with an ambiguous `failed` phase. Activation
uses a conservative zero-delta final gate; post-alias reconciliation handles at most one
configured batch. Completed inactive candidates, as well as cancelled candidates, can be
explicitly cleaned once ownership and actual selection are safe. Reserved bootstrap indices
are retained. These choices keep the planned observable recovery and resource guarantees.

The final scale evidence measures current bounds and recovery. It does not compare an old
implementation lacking journal/run state against the new recovery scenario, or claim a
speedup. Preliminary samples and final hashes are attributed separately in the acceptance
record. No coding-agent trial or original pilot grade was changed.

- Global writer serialization remains a throughput ceiling → shorten final work and measure waits; do not advertise high-load production certification.
- Continuous writes may prevent convergence → bounded retry/failure with the active version available, not indefinite writer suspension.
- Journal/manifests increase database size → expose size and explicit inactive-candidate cleanup; retain mutation history until a separately verified retention policy exists.
- External atomicity differs from PostgreSQL transactions → persist intent, reconcile actual selection, and test stale/ambiguous requests on the pinned server.
- Stable-result retrieval under churn can underfill → return safe current results with incomplete status; never expand the work budget silently.
- Instrumentation tests can accidentally dictate source layout → assert observable contracts with both equivalent positives and intentional faults.

## Migration Plan

1. Add schema and read paths; preserve all existing document IDs, revisions, tenants, outbox and active projection selections. Initialize new journal tracking without converting old events.
2. Fence out old maintenance workers during upgrade; this recipe does not promise mixed-version rebuild workers. Stop maintenance, inspect the alias/version, apply migrations, then start the new worker. Existing untracked inactive candidates are inventoried, not silently adopted or deleted.
3. Exercise small rebuilds and interruption recovery before the bounded scale lane. Keep previous candidates until new selection is confirmed and ownership checks permit cleanup.
4. For rollback, stop new workers and reconcile any pending alias intent first. Revert application code while retaining additive tables and compatible active projections; do not down-migrate operational state automatically. No business-data conversion is needed.
5. Update recipe-local Spec Kit behavior/reconciliation, current docs and evidence only after verification. Merge OpenSpec deltas and archive verified completion; leave hosted release CI pending.

## Primary references

- [Elasticsearch pagination](https://www.elastic.co/docs/reference/elasticsearch/rest-apis/paginate-search-results): PIT/search_after and lifecycle requirements.
- [Elasticsearch aliases](https://www.elastic.co/docs/manage-data/data-store/aliases): multiple actions, per-action failures and must_exist behavior. Verify against the recipe's pinned release.
- [pgvector](https://github.com/pgvector/pgvector): exact versus approximate search and filtering trade-offs.
- Local evidence: `benchmarks/evidence/2026-09-16/pilot-cursor-composer-2.5/OUTCOME.md`; recipe README and current source listed above.
