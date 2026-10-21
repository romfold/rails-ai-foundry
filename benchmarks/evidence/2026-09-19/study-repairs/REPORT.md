# Offline repair evidence — 2026-09-19

These are human-assisted repairs of two saved candidates, not improved coding-agent scores.
The original ten-trial study remains eight passes and two failures, with its original
$0.12507726 accounting. No provider calls or additional coding-agent trials ran.

## Boundary extraction

The original candidate delegated through the public Knowledge API and passed behavior,
but placed configuration at `packs/knowledge/config/foundry.yml`, omitted the namespace,
and included application workflow settings. The repair places schema-1 intent beside
`package.yml`, supplies `Knowledge` / `modular` with independent pattern defaults, and
removes the unnecessary manual autoload path. Root workflow stays `none`.

Fresh verification passes all original behavioral and architecture checks. Separate
fresh-process evidence proves Zeitwerk loading and exactly one discovered context with
path `packs/knowledge`, namespace `Knowledge`, profile `modular`. Existing authorization,
tables and public API delegation remain intact. The original patch remains a failing
architecture control. Foundry now rejects misplaced sidecars even beside a canonical file,
using its existing configuration-error status. Unconfigured upstream packs remain valid.

## Realtime reactions

The original model registered the same callback method for create and destroy. Tracing
showed no reaction creation broadcast; deletion broadcast a replacement of the entire
reactions strip, including its composer. The repair uses distinct committed callbacks,
the existing card stream, entry-level append/remove and stable DOM IDs. HTTP responses
and broadcast echoes address the same entries. The independent permanent composer keeps
other viewers' drafts through broadcasts and Turbo refresh/morph. Only local successful
submission or cancellation resets it. Shared markup does not read request `Current.user`;
viewer controls use the application's existing browser identity convention, while the
server still enforces authorization.

Three fresh-container repetitions each passed the six unchanged upstream browser checks
and six supplemental checks: 12 tests, 70 assertions, no failures/errors/skips. Each also
passed the 1,517-test application baseline with its two pre-existing Vips capability skips
(NIFTI and RAW loaders). The repair is incremental, not a copy of the upstream oracle.

## Fresh verification outcomes

| Candidate/control | Expected | Actual |
| --- | --- | --- |
| boundary-fixed | passed | passed |
| boundary-original | failed | failed |
| realtime-fixed-1 | passed | passed |
| realtime-fixed-2 | passed | passed |
| realtime-fixed-3 | passed | passed |
| missing-delivery | failed | failed |
| duplicate-echo | failed | failed |
| guarded-composer-replacement | passed | passed |
| realtime-original | failed | failed |
| upstream-oracle | passed | passed |
| upstream-noop | failed | failed |
| composer-replacement | failed | failed |

All realtime entries reached task verification after a successful application baseline. The duplicate
echo control failed an explicit single-entry assertion; missing delivery failed live-update
assertions. Destructive composer replacement removed the input and produced Capybara
ElementNotFound errors in the draft/morph checks. These are observable behavior failures,
not application boot or grader availability failures.

The initial matrix expected guarded strip replacement to fail. It correctly passed because
Turbo preserved the permanent composer. `initial-matrix/summary.json` retains that original
expectation mismatch. `acceptance.json` attributes the control-design correction separately;
`unprotected-composer` records the genuinely destructive variant failing the same unchanged
tests. No grader was weakened and no historical study score was changed.

## Evidence and limits

- `patch-composition.json`: original-plus-incremental and complete patches produce identical trees.
- `historical-integrity.json`: all 156 committed original-study files match their recorded Git revision byte-for-byte.
- `boundary-loading/checks.json`: exact context and ordinary Rails loading evidence.
- `foundry-controls/summary.json`: all 45 original controls matched, 24 passes and 21 expected failures.
- `REPOSITORY-CHECKS.md`: core, packaged, workflow, AI, contributor, lint and contract checks.
- [Fixture provenance](../../../repairs/fixtures/provenance.json): source revisions, images, original hashes and repair hashes.

The first supplemental verification had a local test-mount configuration error after a
successful application baseline. `development-mount-error` preserves that infrastructure
failure; `development-supplemental-pass` preserves the corrected run. Neither is a native
attempt. Chromium's blocked update/telemetry requests appear in logs; graders use Docker
`--network none` and installed browser binaries. No external requests were enabled.

Hosted release CI still awaits a repository destination. These checks demonstrate the
saved repairs and regression controls; they do not establish better future agent performance.

The completed change is archived at
[2026-09-19-repair-study-failures](../../../../openspec/changes/archive/2026-09-19-repair-study-failures).
Current context-intent and skill-benchmark specifications include the verified requirements.
