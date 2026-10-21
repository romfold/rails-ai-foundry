# Second-study realtime repair — 2026-09-21

This is **human-assisted regression evidence**, not a new coding-agent result.
The September 21 paid study remains **9 passes / 1 failure**, with its original
$0.11535134 provider-confirmed accounting. No provider calls or coding-agent trials
ran during this repair. Earlier study evidence, repair artifacts and product skills are unchanged.

## Confirmed causes and repair

The saved candidate's six browser checks all failed after its application baseline
passed. [The pre-edit diagnostic](diagnostic.log) shows a committed `body`/`user`
reaction, HTTP 204, a connected card subscription, and no reaction broadcast to that
stream. Registering the same `broadcast_comment` callback for creation and deletion
left one callback identity. The input remained disabled. The existing whole-comment
target did match the DOM; a target-name mismatch was not the cause.

The repair separates creation/deletion commit callbacks and sends entry-level
append/remove messages to the existing card stream. HTTP Turbo Stream responses use
the same stable reaction IDs, so the author updates immediately without duplicate
echoes. A separate permanent composer preserves drafts through remote changes and
explicit refresh/morph. Only successful local submission or cancellation clears it;
a rejected submission shows errors, retains the draft and allows correction.

Shared markup uses the comment's account context without request-user-dependent
controls. The application's client-side viewer identity enables the owner's controls;
server authorization remains authoritative. Deletion now resolves `params[:id]`
inside the authorized comment and rejects another user's reaction with 403. Missing
or unrelated reactions return 404. Tests cover the attacker owning a different
reaction and assert that both records remain intact.

The original `body`/`user` schema, routes, 16-character validation, uniqueness constraint,
and authorized card/comment lookup are retained. This is an incremental repair of
the saved candidate, not a replacement with the upstream reference implementation.

## Acceptance

Three fresh, network-disabled, credential-free containers each passed all **17 tests /
117 assertions**: six byte-identical upstream browser checks and eleven supplemental
checks. Each passed the **1,517-test / 5,708-assertion** application baseline with zero
failures/errors and the same two pinned skips:

- `VipsLoaderPolicyTest#test_denies_NIFTI_files_through_niftiload`
- `VipsLoaderPolicyTest#test_denies_RAW_files_through_dcrawload`

Supplemental checks cover remote deletion, viewer-specific controls, explicit refresh,
cancellation, invalid-submit recovery, rolled-back creation/deletion, inaccessible
cards, mismatched comments, foreign/missing reaction IDs and forged deletion. They
synchronize subscriptions, DOM events and assertions; no sleeps were added.

| Candidate/control | Expected | Actual checks |
| --- | --- | --- |
| final-v4-1 | passed | 17 pass |
| final-v4-2 | passed | 17 pass |
| final-v4-3 | passed | 17 pass |
| guarded-composer-replacement-v4 | passed | 17 pass |
| original | failed | 6 fail |
| missing-delivery | failed | 14 pass, 3 fail |
| duplicate-echo | failed | 13 pass, 3 error, 1 fail |
| composer-replacement-v4 | failed | 15 pass, 1 fail, 1 error |
| wrong-record-deletion-v4 | failed | 14 pass, 3 fail |

Every isolated fault passes the application baseline before failing an explicit
behavioral assertion. The duplicate-echo fault also causes secondary ambiguous-element
lookup errors, and the destructive composer fault retains an upstream lookup error.
The valid alternative replaces the strip while preserving the permanent
composer, demonstrating that acceptance does not require one implementation shape.

Native Le Mans oracle and no-op controls agree with independent fresh verification.
The oracle passes all six original checks. No-op lacks reaction UI and records six
`ElementNotFound` errors after a passing baseline; it is an expected failing upstream
control, not an assertion-based isolated fault. Only this affected upstream task was
selected; replay summaries correctly list the other 41 corpus tasks as unselected.

## Identity and reproducibility

The named set is [realtime-2026-09-21](../../../repairs/sets/realtime-2026-09-21).
[Provenance](provenance.json), [preparation](preparation.json), [outcomes](outcomes.json)
and [commands](COMMANDS.md) record inputs and execution. The existing two-argument
preparer still selects the first study. Named preparation rejects changed study,
task, image, candidate or fixture hashes before creating output.

| Artifact | Identity |
| --- | --- |
| Measured Foundry revision | `13cc872e6ecd53438cf31d0fb7cb8f7034a281c7` |
| Repair starting checkout | `7abf81f` |
| AI-evals revision | `5327efe54dd767d662ab89332f6a4285fef07bd8` |
| Le Mans | `1.3.5`, commit `2d0b7fb8d3b0077574dcf7b70fd4e32c8f9d6e76` |
| Image | `sha256:7a68abbb405addbea91cc7c9ea75c802b63e2603e2f25f51c3c03f92e64b85a0` |
| Original candidate SHA-256 | `19448faa0fa15b013ad0db7b9d32d1bd78ffb78adaf95bdc58044722eca9bc75` |
| Incremental repair SHA-256 | `38da3712ec93b5392fdc77ef14557760669b7134692c027f1e0599708ed0826e` |
| Complete patch SHA-256 | `6b437cf68ee4d68954fe26a3b29fb3997649275bcebf2ab0d6bbb30bfcb08451` |
| Unchanged upstream verifier SHA-256 | `1b952cc16114e5dc09935f63379c19f8bb15d5a8a8eceb4dc1633e3ad0f4be96` |

[Patch equivalence](equivalence.json) proves baseline → original → incremental and
baseline → complete produce tree `3a0deb0147c7f01ec846d7d577ee8479016fbc53`.
The local reconstruction tree IDs complement the portable image/task/patch identities;
local Git commit IDs alone are not portable setup evidence.

[Historical integrity](history-integrity.json) verifies 1,099 prior evidence, earlier
repair and product-skill files against the starting checkout. `files.json` inventories
this separate evidence directory. Original and derived results are never merged or
regraded in place.

## Development failures retained

- `verification/original`: six original assertion failures, unchanged candidate.
- `verification/initial-repair`: the six original browser checks passed before
  supplemental acceptance was complete.
- `verification/repaired-1`: supplemental setup selected another comment's input
  when removing HTML maxlength and created a private card without `Current.user`,
  causing one failure and one error. Both test defects were corrected.
- `verification/accepted-1`: the next supplemental run used `sign_in_as` to change
  identity while retaining the prior session. Its inaccessible-card assertion failed.
  Switching through the existing `logout_and_sign_in_as` helper corrected setup.
- `verification/composer-replacement`: the first fault run raised UI lookup errors
  without an explicit assertion failure. The supplemental refresh check now asserts
  that its open input survives; the final fault run fails that assertion. The six
  upstream checks remain unchanged.
- `controls/oracle-verification`: an independent replay recorded an infrastructure
  failure because the source-only suite lacked `images.json`. The successful replay
  uses a separate suite copy with the pinned image mapping.

All four supplemental-test input generations are preserved in
`input-snapshots.json`; despite its name, `accepted-1` is a **failed** development run.
Only `final-v4-1`, `final-v4-2` and `final-v4-3` count toward final acceptance. The earlier
`final-1` through `final-3` also passed, before an explicit composer-presence assertion
was added to distinguish draft loss from a subsequent element-lookup error.
The application repair patch did not change during these supplemental-test corrections.
Selenium's attempted metadata/telemetry connections fail under the disabled network;
installed browser binaries still execute the tests. These warnings remain in logs.

## Repository verification

- Contributor suite: 61 tests, 316 assertions, no failures/errors/skips.
- Core: 147 tests, 1,133 assertions, no failures/errors/skips.
- Contracts: 10 tests / 142 assertions; eight schema assets and 73 actual cases.
- Full RuboCop: 704 files, no offenses. The two repaired Ruby files also pass the
  pinned application's own Rails Omakase configuration.
- Skills: six development workflows and eight product skills validated.
- Catalog: all twelve executable applications validated.
- Strict OpenSpec: 32 items passed before archive and 31 afterward. The completed
  change is archived at `openspec/changes/archive/2026-09-21-repair-second-study-realtime`.

No Foundry CLI, public schema, product skill or application catalog changes were made.
This repair provides regression evidence for this exact candidate. It does not establish
improved future agent performance or revise the paid study's result.
