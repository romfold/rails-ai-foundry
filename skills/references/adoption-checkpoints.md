# Independently useful adoption checkpoints

Use this reference for an existing application or an explicit context refactor. Adapt the
checkpoints to the authorized change; do not require advanced persistence, events or AI
just because a worked example uses them.

Before editing, identify the selected workflow, actual package roots, owning tables,
public callers and accepted debt. Run `foundry adopt --format=json` for read-only context;
its recommendations are starting points, not proof that migration occurred. For a configured
context, `foundry plan refactor --context=NAME` adds selected-context source evidence.
`complete: true` means the assessment finished. It does not mean a migration is implemented.
Assessment includes the selected package's tests and lib, but excludes independently
discovered nested packages, including children without Foundry intent. Assess configured
children separately; use source checks for general inspection of unconfigured packages.
See [planning guidance](planning.md) for root-package scope and static evidence limits.

| Checkpoint | Evidence before proceeding | Rollback boundary |
| --- | --- | --- |
| Characterization | Endpoints, authorization, tenant isolation, persisted records, failed writes and externally visible errors | No application changes yet |
| Package extraction | Same behavioral tests, ordinary Rails loading, existing table/model identity, declared package dependencies | Move code/configuration back using a recorded patch; retain the unchanged database |
| Public caller repair | An intentional private access fails Packwerk before repair; repaired callers pass; reviewed debt identities are resolved | Restore the prior caller/public API checkpoint; do not silently broaden privacy |
| Separate persistence change | Existing IDs, revisions, ownership, transaction rollback and failure behavior remain equivalent | State whether previous code still understands all written data; take an appropriate backup before irreversible data changes |
| Subsequent features | Integration crash/retry tests, rebuild/tenant/provider evidence relevant to the requested feature | Describe how to disable delivery and recover pending work without losing authoritative state |

For extraction, retain Active Record and current tables unless changing persistence is itself
the authorized task. Establish a useful business boundary first. Keep controllers/views/jobs
with their feature, shared bases in the shell, migrations at root and loading delegated to
packs-rails. Reconcile namespaces and receipts explicitly; preserve custom roots.

Record the starting revision, commands, actual outcomes, files/data changed and rollback
instructions for each checkpoint. Run normal Packwerk checks against unchanged accepted
baselines. Use `foundry audit` in a disposable environment to review new/retained/resolved
identities; edit accepted debt only after that review, never as an automatic way to make
checks pass. A failed checkpoint remains unfinished until repaired or rolled back.

Audit uses one verified capture for accepted debt and independent analyzer copies.
Private agent metadata and `.foundry/skill-upgrades` backups are excluded, as are vendor
baselines; ordinary Foundry receipts remain inputs. Regenerate parity after input-policy
changes even when the gem version is unchanged. A capture is not a sandbox: retain
test-only services and credentials, and review dependencies on excluded files. Keep
reports outside the application; never edit a report fingerprint to bypass stale evidence.

Use the application's selected workflow to record behavior and decisions; keep established
history. With workflow none, a plain checkpoint record and executable tests are sufficient.
Keep application configuration authoritative rather than copying a second dependency graph
into the plan. Report structural, boundary, behavioral and workflow results separately.

For caller-equivalence controls or recoverable background work, read [behavioral and recovery evidence](behavioral-recovery.md). Keep the acceptance tied to the selected checkpoint.

For populated ownership changes, separate extraction from data migration. Establish a trusted
source of ownership; conceal unresolved rows and reject ownership from caller parameters.
Deploy compatible writers before backfill and confirm old writers have stopped. Use bounded
keyset batches with atomic row/progress commits, serialize workers, and review unresolved
IDs explicitly. Validate database invariants outside a short final writer gate; never use
counts alone or perform backfill inside that gate. Keep compatible legacy reads and additive
data for rollback. Test concurrent writes, process death around commit, restart, timeouts,
fresh schema loading and deliberate ownership/authorization faults. The repository-only
`recipes/knowledge-adoption/TENANT-BACKFILL.md` runbook demonstrates this application-specific
sequence; it is not an installed migration service or a requirement for ordinary extraction.
