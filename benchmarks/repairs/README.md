# Offline repairs of saved OpenRouter candidates

These fixtures are human-assisted regression evidence. They do not change the native
study's attempts, grades, patches or accounting, and do not measure future agent performance.
No agent execution or provider credentials are needed.

The two-argument preparer selects the original September 19 fixtures, unchanged.
For the second study, select `realtime-2026-09-21` explicitly. Sets are independent;
the newer candidate uses `body`/`user`, while the earlier one uses `content`/`creator`.

`fixtures/provenance.json` identifies the starting images, source revision, original
candidate hashes and separate incremental/full repair hashes. Its baseline commit IDs
identify the local reconstruction commits; the image and task setup hashes are the
portable starting-application identity. Fresh verification records those inputs again.
The upstream source remains pinned to the revision used by the original study.

## Reproduction

Use managed Ruby 3.4.10, the locked `benchmarks/Gemfile`, Docker, and the frozen study
workspace described in [the study guide](../OPENROUTER_STUDY.md). Prepare a new external
directory; existing output directories are rejected. This copies verifier inputs and
patches only and never starts an agent:

```sh
ruby -EUTF-8 benchmarks/repairs/prepare.rb "$STUDY" "$REPAIRS"
ruby -EUTF-8 benchmarks/suite verify "$STUDY/foundry" boundary-extraction-foundry \
  "$REPAIRS/boundary-complete.patch" "$EVIDENCE/boundary-fixed"
ruby -EUTF-8 benchmarks/suite verify "$REPAIRS/upstream" ft-comment-reaction-live-echo \
  "$REPAIRS/realtime-complete.patch" "$EVIDENCE/realtime-fixed-1"
```

Repeat the last verification into `realtime-fixed-2` and `realtime-fixed-3`. Each call
creates a fresh network-disabled, credential-free container. It runs the application
baseline, the six unchanged upstream browser tests and six supplemental checks.
Subscriptions and browser assertions synchronize delivery; the supplemental tests add
no arbitrary sleeps. The baseline's two pinned Vips capability skips remain explicit.

Run each `missing-delivery-complete.patch`, `duplicate-echo-complete.patch` and
`composer-replacement-complete.patch` through the same derived suite. Each must fail
behavioral assertions, not merely application boot. The corresponding short patches
are faults applied on top of the repaired application. The composer fault both replaces
the strip and removes permanent-element protection. `guarded-composer-replacement-complete.patch`
retains that protection and is a valid alternative control expected to pass; do not reject
it merely for replacing the strip. Original candidate patches are
copied as negative controls; run them with their original suite and requirements.
The upstream oracle and empty no-op patch also use the original upstream suite.

The preparer preserves incremental repair patches separately from complete patches.
The complete faulty patches contain sequential Git diffs: repair followed by fault.
Existing fresh verification applies and checks the actual complete artifact. All
outputs belong in new evidence directories; do not run in-place regrading.

## Changes

The boundary repair moves architectural intent beside `package.yml`, supplies the
Knowledge namespace and independent pattern defaults, and removes the extra manual
autoload path. Application workflow remains `none`; behavior and tables are retained.

The realtime repair separates create/destroy callback identities and broadcasts
committed entry changes to the existing card stream. Stable IDs deduplicate HTTP and
broadcast echoes. A permanent, independent composer preserves drafts during broadcasts
and refresh/morph; only its successful submit or cancel resets it. Shared entry markup
is request-independent. Viewer controls use the application's client-side current-user
convention; server authorization remains authoritative.

Do not copy these candidate patches, task requirements or evaluator tests into product
skills. The reusable skills contain generic placement and behavioral verification guidance.

## September 21 repair set

```sh
ruby -EUTF-8 benchmarks/repairs/prepare.rb "$SECOND_STUDY" "$REPAIRS" realtime-2026-09-21
ruby -EUTF-8 benchmarks/suite verify "$REPAIRS/upstream" ft-comment-reaction-live-echo \
  "$REPAIRS/realtime-complete.patch" "$EVIDENCE/repaired-1"
```

Repeat verification into two more new directories. The selected preparer rejects
mismatched study, task, image, original candidate or fixture hashes before creating
output. It copies the six upstream browser checks without edits and adds eleven
checks for authorization, rollback and composer behavior. The same two baseline Vips
skips remain explicit. The selected study must retain its original `study.json`,
`upstream/` and `results/` layout; output must be a new external directory.

The repaired controller resolves the requested reaction ID inside the authorized
comment and checks ownership. A forged request cannot delete the caller's different
reaction. Invalid submissions keep their draft and permit correction. Distinct
commit callbacks broadcast stable entries, while the permanent composer survives
remote changes and refreshes. Schema, routes and existing validations are retained.

Run `wrong-record-deletion-complete.patch` along with the three faulty variants
listed above. All four must fail assertions after passing the application baseline.
The guarded composer replacement remains a valid alternative. Original candidate
and upstream oracle/no-op controls use the unchanged upstream suite, not the
supplemental repair suite. These are offline controls, never live agent attempts.

`sets/realtime-2026-09-21/provenance.json` records the original candidate hash,
incremental and complete patch hashes, supplemental test hashes and reconstructed
tree identities. [The dated report](../evidence/2026-09-21/second-study-repair/REPORT.md)
records verification, failed development checks and patch equivalence. The paid
study remains **9 passes / 1 failure**.

## Guidance-study repair set

Select `realtime-guidance-2026-09-21` for the later study at `ce57b26`. This candidate
uses `content`/`creator`; it is a different patch from both earlier repairs.

```sh
ruby -EUTF-8 benchmarks/repairs/prepare.rb "$GUIDANCE_STUDY" "$REPAIRS" realtime-guidance-2026-09-21
ruby -EUTF-8 benchmarks/suite verify "$REPAIRS/upstream" ft-comment-reaction-live-echo \
  "$REPAIRS/realtime-complete.patch" "$EVIDENCE/repaired-1"
```

Use fresh output directories for the second and third acceptance. The derived suite
retains the six upstream browser checks and adds fourteen checks for authorization,
committed publication/rollback, rendered deletion forms and local drafts. Named-set
validation rejects mismatched study, source/task/image/candidate and fixture hashes.
The incremental and complete repair must reconstruct the same tree.

Expected-failure controls are `callback-collision`, `malformed-deletion`,
`duplicate-echo`, `composer-replacement`, `sender-controls` and `wrong-record-deletion`;
verify each `-complete.patch` through the derived suite. They must pass the application
baseline and fail behavioral assertions. The guarded composer replacement must pass.
Run `original.patch` and upstream oracle/no-op controls through the original suite.

The contributor-only `diagnostics.rb` demonstrates both original causes in an
unrepaired disposable application with the original verifier mounted at `/tests`:

```sh
docker exec -i "$DIAGNOSTIC_CONTAINER" ruby -e 'File.binwrite(ARGV.fetch(0), STDIN.read)' \
  /tmp/diagnostics.rb < benchmarks/repairs/sets/realtime-guidance-2026-09-21/diagnostics.rb
docker exec "$DIAGNOSTIC_CONTAINER" ruby -Itest /tmp/diagnostics.rb --include /diagnostic/
```

It records request status, committed content, effective callback actions, subscriptions,
broadcasts and rendered form attributes. Use the pinned image and candidate named by
the set's provenance; prepare its test database before running this diagnostic.
Do not run it against the repaired application, where its defect assertions should fail.

The [guidance-study repair report](../evidence/2026-09-21/guidance-study-repair/REPORT.md)
keeps all development failures and accepted offline results separate from the original
paid study, which remains **9 passes / 1 failure**. No live trial or provider request
is part of repair preparation or verification.

## September 22 profile and realtime repairs

Select both saved candidates with the new named set:

```sh
ruby -EUTF-8 benchmarks/repairs/prepare.rb FROZEN_STUDY NEW_OUTPUT profile-realtime-2026-09-22
```

Preparation validates the study and both task/image/candidate identities before
creating separate `upstream/` and `foundry/` suites. The output includes
`boundary-original.patch`, `boundary-repair.patch`, `boundary-complete.patch`,
`original.patch`, `realtime-repair.patch` and `realtime-complete.patch`. Incremental
repairs apply after their original candidate; complete patches apply to the sealed
baseline. Provenance records their hashes and equivalent reconstructed trees.

The boundary changes only the requested Knowledge profile. Realtime fixes schema
reconstruction, UUID references, control sizing, committed entry delivery and draft
preservation while retaining the candidate's routes and `content`/`creator` fields.
The six upstream checks remain unchanged; fifteen supplemental checks cover
authorization, rollback, actor/viewer behavior, drafts and visible controls.

Controls preserve the original candidates and schema-only correction. Isolated
`callback-collision`, `zero-size-controls` and `composer-replacement` variants must
fail behavior after loading; `guarded-composer-replacement` remains a valid alternative.
Use the existing fresh verifier for every complete patch. The separate
[repair report](../evidence/2026-09-22/profile-realtime-repair/REPORT.md) records actual
outcomes. The paid study remains eight passes, one failure and one infrastructure
error. Repairs do not create new native attempts or authorize provider calls.
