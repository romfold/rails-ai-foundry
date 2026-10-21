# Guidance-study realtime repair — completed 2026-09-22

This is **human-assisted regression evidence** for a saved candidate, not a new
coding-agent score. The paid guidance study remains **9 passes / 1 failure**, with
its original **$0.12277142** provider-confirmed accounting. No paid calls or new
coding-agent trials ran. All prior study and repair evidence is unchanged.

## Confirmed causes and repair

[The original causal diagnostic](causal-diagnostics-final.log) records a committed
reaction after HTTP 200, connected subscriptions, and no reaction publication to
the card stream. Rails retained one `broadcast_reactions` callback: its effective
conditions accepted destruction but not creation. Registering that method for both
commit hooks had replaced the creation registration.

The original deletion helper also treated its arguments incorrectly. The browser
rendered a POST form targeting the creation endpoint, with button options in the
query string, a URL as its button label, no deletion CSS control, and no DELETE
override. Attempting it produced another create request with HTTP 400. These are
observed failures against the pinned image, not deductions from source alone.

The incremental repair uses distinct creation/deletion commit callbacks and
entry-level append/remove broadcasts to the existing card stream. Matching HTTP
Turbo Stream responses use stable reaction IDs so response and broadcast echoes
do not duplicate entries. An explicit `button_to` block supplies a working delete
control, its accessible label, CSS class and DELETE override; a browser check
verifies the actual target and resulting record deletion.

Shared entries use the comment's account context without the originating request's
user. Browser-local viewer identity controls the owner's UI, while server-side
authorization remains authoritative. Requested reaction IDs are resolved inside
the authorized comment: foreign ownership returns 403, and unrelated/missing
records return 404. The caller's different reaction cannot be substituted.

A separate permanent composer preserves drafts through broadcasts and explicit
refresh/morph. Only successful local submission or cancellation resets it. A 422
response shows validation errors while retaining editable input and permitting a
retry. The original `content`/`creator` schema, routes, 16-character validation,
uniqueness constraint and authorized card/comment lookup are retained.

## Acceptance and controls

Three fresh, credential-free, network-disabled containers each passed **20 tests /
140 assertions**: six byte-identical upstream browser checks and fourteen
supplemental checks. Every accepted repair/control run first passed the
**1,517-test / 5,708-assertion** application baseline, retaining these two pinned skips:

- `VipsLoaderPolicyTest#test_denies_NIFTI_files_through_niftiload`
- `VipsLoaderPolicyTest#test_denies_RAW_files_through_dcrawload`

Supplemental checks cover committed creation/deletion and rollback, rendered forms,
actor/viewer controls, remote deletion, preserved drafts and refresh, cancellation,
invalid submission/retry, inaccessible cards, mismatched comments, and foreign or
missing reaction IDs. Subscriptions and DOM assertions synchronize delivery; no
sleeps were added. Supplemental interactions scroll the comment into view before
clicking to avoid the application's floating notification control.

| Candidate/control | Expected | Actual checks |
| --- | --- | --- |
| repaired-scrolled-1 | passed | 20 pass |
| repaired-scrolled-2 | passed | 20 pass |
| repaired-scrolled-3 | passed | 20 pass |
| guarded-composer-replacement-final | passed | 20 pass |
| original | failed | 2 pass, 3 fail, 1 error |
| callback-collision-final | failed | 15 pass, 5 fail |
| malformed-deletion-isolated | failed | 14 pass, 3 fail, 3 error |
| duplicate-echo-final | failed | 14 pass, 1 fail, 5 error |
| composer-replacement-final | failed | 18 pass, 1 fail, 1 error |
| sender-controls-final | failed | 19 pass, 1 fail |
| wrong-record-deletion-final | failed | 17 pass, 3 fail |

Each isolated fault has an explicit behavioral assertion failure after baseline
success. Duplicate rendering also produces ambiguous-element errors. The malformed
form retains missing-control errors, and its first isolated run also records an
intercepted upstream click. These errors are not counted as additional independent
test cases. The valid alternative replaces the strip while preserving its permanent
composer, proving acceptance does not enforce a single implementation shape.

Native Le Mans oracle and no-op controls use `offline-controls`, zero steps, zero
tokens and zero model cost. Fresh verification ultimately agrees: the oracle passes
six checks; no-op lacks reaction UI and records six expected element-lookup errors.
Only this affected task was selected; the other 41 corpus tasks were not rerun.

The first oracle replay disagreed because the pre-existing notification overlay
intercepted an upstream click. Its native artifact and failed independent replay
remain intact. A separate recheck at lower concurrency passed the same six tests
with the same patch and environment. This documents a browser flake, not a silently
rewritten result or a guarantee of deterministic upstream acceptance under all load.

## Identity and reproduction

The named fixture set is [realtime-guidance-2026-09-21](../../../repairs/sets/realtime-guidance-2026-09-21).
[Provenance](provenance.json), [preparation](preparation.json), [outcomes](outcomes.json),
[input snapshots](input-snapshots.json), and [commands](COMMANDS.md) record the inputs.
The two-argument preparer and earlier named set still work against their original
studies. Named selection rejects study/task/image/candidate or fixture mismatches
before output is created.

| Artifact | Identity |
| --- | --- |
| Measured Foundry revision | `ce57b2657398ffca89715e3d28e82bc360829790` |
| Repair starting checkout | `f51e25045727c19ab4acb882fbff9b8cf1c61877` |
| AI-evals revision | `5327efe54dd767d662ab89332f6a4285fef07bd8` |
| Le Mans | `1.3.5`, commit `2d0b7fb8d3b0077574dcf7b70fd4e32c8f9d6e76` |
| Image | `sha256:7a68abbb405addbea91cc7c9ea75c802b63e2603e2f25f51c3c03f92e64b85a0` |
| Original candidate SHA-256 | `0cba1a704df26b74a226492686c57e9c817fba73a4a2ae8d79112ea1cb952f78` |
| Incremental repair SHA-256 | `975822717702c84463890bf387d9d70b94c0794b1569d7813b69cfa8ef679e76` |
| Complete patch SHA-256 | `e66ee4c0bfecb0c8ab0ea0b6a528b06d4946bee198953358a3c456570d180fbe` |
| Unchanged upstream verifier SHA-256 | `1b952cc16114e5dc09935f63379c19f8bb15d5a8a8eceb4dc1633e3ad0f4be96` |

[Patch equivalence](equivalence-final-assertions.json) proves baseline → original →
incremental and baseline → complete produce the same tree:
`b81119ae7d56320edef6de3acb233d6dae2686d7`. Subsequent test/control adjustments did not
change either repair patch. The task/image/patch identities supplement local Git
trees; a local reconstruction commit alone is not portable evidence.

[Historical integrity](history-integrity.json) verifies **1,656** pre-existing study
and prior repair files against the starting checkout. [Skill hashes](skill-hashes.json)
separately identify the intentionally updated guidance. `files.json` inventories
this new evidence directory without rewriting any original study.

## Development failures retained

- `verification/original`: two original checks passed, three failed assertions and
  one had a missing-control error. Missing broadcasts masked additional defects.
- `verification/repaired-dev1`: supplemental setup incorrectly used `Current.creator`.
  `verification/repaired-1` and the early `callback-collision` run then exposed
  `Comment.content`; the comment still uses `body`. Both fixture mistakes were fixed.
- `verification/repaired-accepted-1` passed before an explicit delete-button assertion
  was added. `verification/repaired-final-1` also passed; neither is one of the final
  three repetitions with centered supplemental interactions.
- `verification/malformed-deletion-final`: the initial fault raised route-generation
  errors during request-independent rendering. The isolated form fault supplies
  explicit route context but retains the incorrect helper argument interpretation,
  allowing browser assertions to reject the missing delete control.
- `verification/repaired-final-2`: 19 checks passed; a floating notification control
  intercepted one supplemental click. Supplemental tests now center the comment
  before interaction. All three `repaired-scrolled-*` runs passed afterward.
- `controls/oracle-verified`: the same overlay intercepted an unchanged upstream
  oracle click. `controls/oracle-verified-recheck` preserves its separate successful
  recheck; the first disagreement is retained.
- Diagnostic setup first attempted a copy into a read-only container filesystem,
  then encountered a stale browser element. The failed logs and final passing
  diagnostic are retained. Application RuboCop found one extra blank line; root
  RuboCop required moving the new test class into its own file. Final checks pass.
- An attempted `suite prepare-repairs` invocation was rejected as an unknown
  command before preparing output. The existing standalone `repairs/prepare.rb`
  interface was then used; no new suite or Foundry CLI command was introduced.
- The report-link check initially inherited US-ASCII and rejected Unicode text;
  it was rerun with explicit UTF-8. This did not change candidate or grading files.

The seven preparation generations retain exact test contents and hashes. The
accepted callback and malformed-form faults used inputs before the later scroll
setup adjustment; they already failed explicit behavioral assertions. Final repaired
repetitions and remaining controls use `prepared-scrolled`. Selenium's blocked
metadata/telemetry requests remain visible in logs; installed browsers ran offline.

## Reusable guidance and repository verification

The existing feature, event and verification skills explicitly load the shared
behavioral reference for realtime/Hotwire work. Its new generic guidance checks
effective commit callbacks, rendered form actions/methods and actor/viewer behavior.
No candidate answer, benchmark requirement or evaluator fixture enters product skills.

- Contributor tests: **70 tests / 579 assertions**, all pass.
- Core tests: **147 tests / 1,134 assertions**, all pass.
- Full packaged acceptance: **6 tests / 428 assertions**, all pass. A subsequent
  focused replay adding customized skill-entrypoint preservation passes **2 tests /
  208 assertions** for `packs/` and `components/`. It also checks customized references,
  workflow `none`, receipts, accepted debt and actual caller behavior.
- Full RuboCop: **710 files**, no offenses; the later changed supplemental/packaging
  files also pass focused checks. Both repaired Ruby files pass the pinned
  application's own Omakase configuration.
- Skills: **six development workflows and eight product skills** validated.
  Catalog: **twelve executable applications** validated.
- Contracts: **10 tests / 142 assertions**, eight schema assets and 73 actual cases.
- Strict OpenSpec: **32 items passed** before archive and **31 afterward**. The
  completed change is [archived with its verified checklist](../../../../openspec/changes/archive/2026-09-22-repair-guidance-study-realtime/tasks.md).

Repository test summaries come from the executed command transcript; per-candidate
baseline/task logs and machine outcomes are preserved in this evidence directory.
Raw evidence and patch whitespace is retained; it is not autoformatted into a
different artifact. Source files pass their applicable formatting checks.

No Foundry CLI command, public schema, runtime, provider, catalog application or
benchmark task variant was added. This repair proves the saved candidate's behavior
and improves reusable guidance; it does not revise the paid score or establish
improved future agent performance. Hosted release CI and publishing remain separate.
