# Review installed skill upgrades

Updating the gem makes new templates available. It does not update installed skills,
application code or behavior. Ordinary `foundry:skills` generation still preserves a
complete customized installation and refuses replacement of a different catalog.
This explicit workflow supports complete current eight-skill receipts for `agents`,
`claude` and `cursor`. Historical catalogs retain the manual review procedure in
[stable contracts](stable-contracts.md).

## Assess and apply

Use a reviewed branch and the selected gem's locked bundle. Stop other agents/editors
from changing skill files while applying an upgrade. No specification workflow, model
credentials or Foundry source checkout is required.

```sh
bin/rails generate foundry:skills --upgrade --target=agents
bin/rails generate foundry:skills --upgrade --target=agents --apply=REVIEW_DIGEST --pretend
bin/rails generate foundry:skills --upgrade --target=agents --apply=REVIEW_DIGEST
```

Replace `REVIEW_DIGEST` with the printed digest. Assessment and pretend write nothing.
A digest includes the target, original receipt, incoming catalog, installed bytes/modes,
planned actions and previous upgrade history. Version equality does not hide changed
content. If inputs changed, assess again; do not edit hashes to bypass refusal.

| Classification | Apply behavior |
| --- | --- |
| unchanged/current | Already matches upstream; preserve bytes and mode |
| customized | Only local content changed; preserve it |
| update | Unmodified owned file receives the upstream content |
| add | New upstream file is created only at an unoccupied destination |
| remove | Unmodified retired file is removed |
| review | Both sides changed, or a customized file was retired; keep local content pending review |

Malformed receipts, missing owned files, occupied new paths, symlinks and invalid
ownership block the operation before installed files change. Restore the reviewed
installation first; upgrades are not a general damaged-install repair facility.
New files use mode 0644; changed existing files retain their mode.

## Resolve pending review

Safe updates can finish while conflicts remain. The command returns nonzero with
**Safe updates applied; review pending**, and leaves the original receipt unchanged.
Ordinary generation refuses while this session is active. Review artifacts are under
`.foundry/skill-upgrades/TARGET/SESSION_ID/`, outside skill discovery:

- `plan.json`: original/proposed snapshots, modes and actions; immutable provenance.
- `local/` and `upstream/`: readable copies for conflicting files.
- `decisions.json`: explicit decision template, initially `REVIEW_REQUIRED`.
- `state.json`: recoverable progress and accepted decisions/customization hashes.

The previous receipt stores hashes, not old template text: these copies do not claim
a three-way merge. Review copies and backups can contain private application guidance;
keep the private directory local, review before sharing, and do not alter its plan/state.
A new backup root includes a Git ignore file; existing ignore rules are preserved.
Forced Git additions and other sharing tools can still expose these backups.
Commit installed files and the final receipt as normal; retain private backups for rollback.

For every listed file, replace `REVIEW_REQUIRED` with exactly one choice:

| Decision | Meaning |
| --- | --- |
| `keep_local` | Explicitly retain reviewed installed content; a retired file becomes unmanaged |
| `use_upstream` | Accept incoming content, or deletion when upstream retired the file |
| `merged` | Accept a manual edit already made to the installed file; unavailable for retired files |

Use an application-relative decisions-file path. The JSON document must contain `session` and `files`; each path contains `decision`
and `sha256` for the **currently reviewed installed bytes**. After a manual edit,
calculate its digest using `ruby -rdigest -e 'puts Digest::SHA256.file(ARGV.fetch(0)).hexdigest' PATH`
and place that value in the decision. This authorizes the decision on those bytes; it
does not rewrite the installation receipt or assert that the file is upstream content.

```sh
bin/rails generate foundry:skills --upgrade --target=agents --resolve=.foundry/skill-upgrades/agents/SESSION_ID/decisions.json
```

Every pending file must have a valid decision before resolution writes anything.
Successful resolution publishes the incoming template receipt and separately retains
actual accepted customization hashes. Repeated generation preserves those edits. A
later upstream change can require another explicit decision; already accepted local
customizations do not continually reopen when their upstream template is unchanged.

## Interruption and rollback

```sh
bin/rails generate foundry:skills --upgrade --target=agents --apply=REVIEW_DIGEST
bin/rails generate foundry:skills --upgrade --target=agents --rollback=SESSION_ID --pretend
bin/rails generate foundry:skills --upgrade --target=agents --rollback=SESSION_ID
```

Repeat the same apply to recover interrupted writes or resolution. Repeat rollback
if rollback itself was interrupted. Each write has recorded before/after states;
unknown edits block recovery. Rollback preflights all affected paths and restores
original bytes/modes and receipt only when they still match recorded states. It never
forces later edits away. Completed journals remain available; a new assessment after
rollback creates a new review identity rather than replacing historical evidence.

Writes use a nonblocking POSIX application-directory lock, conservatively serializing
all targets, atomic individual replacements and synced journals. They do not provide
multi-file atomic visibility or defend against a malicious same-user filesystem racer.
Other agents must not consume a partially upgraded catalog. Backup storage remains
application-owned; this scope does not implement automatic cleanup.

Successful assessment/completion returns zero. Pending review, stale input, blocked
recovery and I/O failures return nonzero with distinct messages. `--apply`, `--resolve`
and `--rollback` require `--upgrade` and are mutually exclusive. Never combine a
mutation with generator destroy mode. Pretend creates no upgrade artifacts.

## Verify the result

Review instructions and script changes, then run the installed verification helper
against the application's selected HTTP/browser tests. Include a disposable known-fault
control when changing verification behavior. See [verification guidance](../skills/foundry-verify/references/verification.md).
A new helper is not evidence of working application behavior, stronger agent compliance,
or required CI enforcement. Keep existing workflow history, package roots and accepted
debt unchanged. No provider or agent-study execution is needed for an upgrade.

## Delivering RSpec verification

The RSpec adapter is delivered as owned verification scripts through this same assessment,
apply and explicit-resolution workflow. Assess with the new gem, review customized helper
files, resolve every conflict, then repeat ordinary generation to verify preservation.
Execute the installed helper with `--framework=rspec` and real request/system selections;
replacement of files alone does not establish behavior. Minitest remains the default.
See the [verification contract](stable-contracts.md) for native outcomes and evidence limits.
