# Bounded knowledge operations

This runbook applies to the independent
[knowledge recipe](../recipes/domain-knowledge-rag-rom-res-elasticsearch-pgvector/README.md "Repository-only reference; not installed").
These are application-owned Rails/ROM/Elasticsearch operations, not Foundry runtime APIs.
The application still uses demo bearer-token authentication. Maintenance requires trusted
shell/database access; no maintenance HTTP endpoint or agent tool is exposed.

## Read and work limits

The recipe's `config/initializers/knowledge_limits.rb` owns limits outside Foundry's schema:

| Operation | Default / bound |
| --- | --- |
| Tenant document page | 50 / 100 rows, UUID keyset cursor |
| Delivery status | Aggregated only for authorized page IDs |
| Retrieval | Five documents, at most 100 candidates across refill attempts |
| Snapshot / manifest / journal batch | At most 250 rows |
| Elasticsearch bulk | At most 1 MiB of serialized request data |
| Run lease | 30 seconds; conditional progress updates use a fresh fencing token |
| Reported failures | Backoff up to 60 seconds; quarantine after five failures |
| Final writer gate | Ten-second checked budget, two-second SQL/lock/request timeouts |

Document JSON uses `{documents: [...], next_cursor: ...}`; pass `after` for subsequent
pages. A final full page can lead to an empty next page. The adoption walkthrough preserves
its original array response and returns pagination through `X-Next-Cursor` instead.
Retrieval and authorized tool results contain `documents` and `incomplete`. An incomplete
result means the candidate budget prevented filling five results, not permission to use
unvalidated data. Answer output propagates the flag and independently checks citations.

Exact pgvector distance ordering applies tenant and active-version predicates in SQL,
with document ID breaking ties. Knowledge revalidates visibility and revision before
results leave Search. SQL LIMIT bounds returned Ruby rows; exact search can still scan
and sort many database rows. These limits do not promise constant database CPU.

## Start, inspect and resume

Run from the recipe with its own locked bundle and the intended Rails environment:

```sh
bundle exec rake projections:start DESTINATION=search
bundle exec rake projections:start DESTINATION=vectors VERSION=demo-v2
bundle exec rake projections:status
bundle exec rake projections:status RUN_ID=<returned-uuid>
bundle exec rake projections:resume RUN_ID=<returned-uuid>
```

Start records a candidate, committed journal fence, finite scan upper bound and batch
options. Only one nonterminal run per destination is allowed. Status without an ID returns
the latest 20 runs, phase, processed count, lag, retry/quarantine state and safe error class;
it omits the lease token. Do not change batch options while resuming a recorded run.

Resume performs one recoverable unit. Solid Queue's recurring poller also discovers
pending database rows. A lost scheduling request does not lose work. After a worker dies,
wait for its lease to expire; another worker can then claim a new token. An old worker
cannot acknowledge progress. Abrupt deaths do not increment reported-failure quarantine.
Provider work runs outside writer transactions and is rechecked before persistence.

After fixing a reported provider, destination or candidate failure, explicitly clear
quarantine and execute one unit:

```sh
bundle exec rake projections:resume RUN_ID=<uuid> REPAIR=1
```

Inspect the safe error class and destination state first. Missing journal history must
not be bypassed or fabricated. Missing/corrupt candidates must not be declared valid from
counts alone. Cancel a pre-cutover run and start a fresh candidate after repairing the
cause. Retain journal entries and source tombstones; pruning is not implemented.

## Activation and uncertain outcomes

Backfill writes before checkpointing. A replay uses the same candidate and external
document revisions. Persisted manifests validate identity, revision and content in pages,
including float32 embedding digests. Counts additionally reject unexpected membership.
Journal replay catches creates behind the scan cursor, edits, withdrawals and deletion.
Journal predecessors distinguish missing history from normal rolled-back sequence gaps;
the writer gate, rather than sequence allocation alone, establishes committed order.

Validation and providers run outside the final gate. The implementation conservatively
requires **zero pending deltas** for activation: otherwise it releases the gate and resumes
asynchronous catch-up. Vector selection uses a short database transaction. Elasticsearch
persists cutover intent before a guarded expected-prior removal plus candidate addition.
Tests exercise the actual `must_exist` failure semantics of server/client 9.3.0.

An acknowledgment timeout is an **unknown outcome**, not proof of failure. The run freezes
candidate backfill, cancellation and cleanup. Resume inspects the actual alias:

- Prior selection still present: retry only the same guarded action.
- Candidate selected: replay bounded post-fence changes, then mark complete.
- Missing, multiple or unrelated selection: stop for explicit operator investigation.

Never blindly revert the alias or start a competing activation to repair uncertainty.
Keep the reserved `*_initial` bootstrap index: its atomic index-and-alias creation prevents
a delayed initializer from reintroducing an old selection. Do not manually delete it.

Post-cutover reconciliation handles at most one configured batch inside a gate. Its
requests have bounded timeouts. A request already in flight can exceed the checked gate
budget by its timeout; this is not a hard ten-second wall-clock interrupt. The global
advisory writer gate remains a throughput limitation. Sustained mutation can prevent
convergence; inspect lag and schedule a quiet maintenance window rather than enlarging
an unbounded final critical section.

## Cancel and cleanup

```sh
bundle exec rake projections:cancel RUN_ID=<uuid>
bundle exec rake projections:cleanup RUN_ID=<uuid>
bundle exec rake projections:cleanup RUN_ID=<uuid> CONFIRM=delete
```

Cleanup defaults to a preview. It only accepts cancelled or completed candidates that are
inactive, unleased and have no unresolved cutover. A cancelled live worker is fenced, but
cleanup waits for lease expiry. Completed candidates can be removed after a later activation
replaces them. Operational run and manifest rows remain for evidence; cleanup removes the
destination projection only. No automatic cleanup or journal retention job is installed.

## Upgrade and rollback

1. Stop old maintenance and delivery workers; do not run old and new rebuild code together.
2. Inventory active aliases/vector selection and existing inactive indices/versions.
   Untracked historical candidates are not automatically adopted or deleted.
3. Back up normally, then run `bundle exec rails db:migrate`. Four additive operational
   migrations introduce journal links, runs, manifests, retries and captured options.
   Business documents and existing integration events are not converted.
4. Verify loading and status, then restart the application-owned poller. Only recorded
   runs are resumable; new runs include existing business rows in their bounded scan.

For rollback, stop workers and reconcile every pending cutover intent **before** reverting
code. Retain additive operational tables and journal history. Do not use schema rollback
to erase the evidence needed to resolve an uncertain alias outcome.

Notifications ending in `.knowledge` report durations, bounded batch rows/bytes, candidate
counts and safe failure classes. Operator status provides attempts, lag and progress.
Document bodies, prompts, credentials and raw exception messages are excluded from these
telemetry payloads. Manifests contain document content for validation and require the same
database access controls as source documents; they are not telemetry.

See the [acceptance and measurement record](knowledge-operations-evidence.md) for commands,
source hashes, process-failure tests and limits of the measured evidence.
