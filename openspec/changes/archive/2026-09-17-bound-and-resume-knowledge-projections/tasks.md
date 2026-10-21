## 1. Bounded read path

- [x] 1.1 Add keyset document pages and page-scoped delivery status in Knowledge's public API; verify multi-page traversal, custom tenant isolation, bounded returned rows and unchanged document identity.
- [x] 1.2 Move vector tenant/version filtering and candidate limits into SQL, with bounded refill and authoritative revision revalidation; verify exact ordering on a static dataset, deletion/withdrawal races and explicit incomplete results after the candidate budget.
- [x] 1.3 Update owning Rails delivery and authorized tools for pagination/incomplete outcomes; verify endpoint/tool contracts, unauthorized requests, zero results and unchanged citation safety against real PostgreSQL/pgvector.

## 2. Persisted rebuild work

- [x] 2.1 Add root migrations for Knowledge mutation history and Search rebuild runs/manifests; verify existing IDs, revisions, active selections and outbox rows survive migration and rollback of failed business commands also removes journal intent.
- [x] 2.2 Expose paged snapshots and commit-safe fences through Knowledge's public API; verify concurrent creates behind the page cursor, rollback sequence gaps, delayed writers and missing-history rejection without private cross-pack persistence access.
- [x] 2.3 Add run start/claim/resume/cancel state transitions with conditional checkpoints and fencing tokens; verify competing workers, expiry, parameter mismatch, candidate loss, cancellation and lost queue wake-ups.
- [x] 2.4 Implement bounded Elasticsearch bulk backfill and manifest updates; verify row/byte caps, partial bulk failures, obsolete revisions and process death after destination persistence but before checkpoint acknowledgment.
- [x] 2.5 Implement resumable vector batches outside provider transactions; verify failed providers, revision changes, duplicate recomputation, independent versions and preservation of the active version after interruption.

## 3. Validation, cutover and recovery

- [x] 3.1 Add paged identity/revision/content validation and journal catch-up; verify extra/missing/corrupt candidate entries, tombstones, multi-page changes and interrupted validation without a corpus-sized Ruby collection.
- [x] 3.2 Replace final full scans with bounded reconciliation and activation; verify the final batch/time limits, no provider calls/full-corpus reads under the gate, healthy writes after budget exhaustion and no selection change on pre-cutover failure.
- [x] 3.3 Persist and reconcile Elasticsearch cutover intent with guarded alias actions on pinned 9.3.0; verify per-action failures, actual alias outcomes after dropped responses, stale delayed requests and crashes before local acknowledgment.
- [x] 3.4 Fence candidate mutation/cleanup during uncertain cutover and replay post-fence changes into the confirmed active target; verify cancellation, lease replacement and concurrent writes cannot lose committed changes or revert a newer selection.
- [x] 3.5 Add operator-only Rake maintenance tasks and tenant-safe progress delivery with existing notifications; verify authorization, payload redaction, recovery counters and cleanup dry-runs refusing active/unresolved/leased candidates.

## 4. Executable guidance and scale evidence

- [x] 4.1 Add a process-recovery acceptance lane using disposable services and explicit synchronization; verify kill/restart at persistence, checkpoint and cutover boundaries, lease reclamation, temporary destination outage and successful eventual completion.
- [x] 4.2 Add bounded runtime measurements for 1,000/10,000-document deterministic datasets; verify configured page/candidate/byte limits, record query counts/RSS/allocations/latency/gate/recovery results and enforce the ten-minute scenario/thirty-minute total budget with honest timeout outcomes.
- [x] 4.3 Add a shared behavioral/recovery verification reference to applicable existing skills, using the skill-creator workflow; verify direct/delegated/relocated positive controls and structural-pass/behavioral-fail controls, without imposing universal same-pack service wrappers.
- [x] 4.4 Replay the new guidance through existing installed-gem first-feature/adoption harnesses with packs/ and components/ roots; verify selected workflow preservation, existing debt, customized skill receipts and all eight skill identities.

## 5. Reconciliation and completion

- [x] 5.1 Extend the existing independent recipe CI lane with a multi-page offline correctness/recovery dataset; verify its commands locally with the recipe lock and prohibit live providers or coding-agent execution.
- [x] 5.2 Publish the runbook, resource limits, source/measurement hashes, exact commands and known operational limits; verify links and distinguish measured runtime behavior from unchanged September 16 agent evidence and demo authentication.
- [x] 5.3 Run recipe bin/verify, production loading, Packwerk and recipe RuboCop plus core tests, installed-gem acceptance, relevant AI/workflow lanes, root RuboCop, contracts and skill/catalog validation; record actual results and resolve demonstrated regressions.
- [x] 5.4 Reconcile recipe-local Spec Kit artifacts and current documentation, validate strict OpenSpec, sync verified requirements and archive with focused Conventional Commits; verify all task evidence exists and leave hosted release CI/publication and further agent trials outside completion.
