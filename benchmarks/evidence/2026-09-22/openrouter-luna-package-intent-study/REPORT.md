# Paid study after package-intent guidance — 2026-09-22

Ten fresh GPT-5.6 Luna medium attempts ran once each at revision
`81889926643dc7a67757205da480769af3a9696b`. Native Le Mans records **9 passes and
1 failure**. Fresh independent verification records **9 passes and 1 infrastructure
error**: the realtime candidate's pending migration prevented baseline reporting.
Its six browser requirements did not execute. This is not ten verified passes.

All six Foundry comparison attempts pass, including both cells receiving the installed
Foundry gem and skills. Smoke passes separately. The upstream sample has two passes
and one unavailable independent grade. No submitted candidate was repaired; no trial
was retried. Historical studies and human-assisted repair evidence remain unchanged.

## Outcomes

| Task | Native / independent | Reported USD | Steps | Input + output tokens | Native seconds |
| --- | --- | ---: | ---: | ---: | ---: |
| hello-world (smoke) | pass / pass | 0.00201454 | 4 | 8,917 | 58.9 |
| boundary-extraction-rails | pass / pass | 0.00773811 | 11 | 63,463 | 63.8 |
| boundary-extraction-packs | pass / pass | 0.01500201 | 16 | 193,793 | 102.8 |
| boundary-extraction-foundry | pass / pass | 0.01278739 | 14 | 163,595 | 82.6 |
| stale-embedding-rails | pass / pass | 0.00792004 | 10 | 59,764 | 71.2 |
| stale-embedding-packs | pass / pass | 0.00690034 | 8 | 38,658 | 66.4 |
| stale-embedding-foundry | pass / pass | 0.00811724 | 9 | 57,844 | 79.0 |
| ar-tenant-isolation | pass / pass | 0.02345407 | 17 | 380,949 | 179.1 |
| aj-enqueue-after-commit | pass / pass | 0.01001886 | 10 | 111,338 | 123.7 |
| ft-comment-reaction-live-echo | fail / infrastructure error | 0.03751111 | 30 | 893,635 | 200.0 |

There are ten attempted native trials, nine completed independent assessments,
zero recorded prohibited edits, zero completed-grade disagreements, zero resource
stops and zero unstarted trials. An unavailable grade is not grader agreement.
Native duration includes setup and native grading, but excludes independent replay.
Token totals include repeated/cached input; original usage and cost sources are retained.

## Shipped package guidance exercised successfully

The preceding study's Foundry boundary candidate selected `rails_native` despite
an explicit `modular` requirement. The measured revision fixes the shared package
reference and existing package/adoption skills: resolve selected architecture before
copying example configuration, preserve existing context intent, use application
defaults for new contexts and compare actual assessment values with that selection.
The generic checker continues accepting every valid supported profile.

The fresh [boundary trajectory](results/03-boundary-extraction-foundry/gpt-5.6-luna-medium/boundary-extraction-foundry__aUpa920/trajectory.json)
reads root configuration and the revised package reference, writes a pack-root sidecar
with namespace `Knowledge` and profile `modular`, and inspects it after checking.
Both shared behavioral checks and the required architecture assessment pass.
See the [actual Foundry report](verification/03-boundary-extraction-foundry/gpt-5.6-luna-medium_boundary-extraction-foundry__aUpa920/foundry.json).
This is fresh agent evidence using shipped instructions, without a repaired answer.
One observation does not establish a causal effect or future reliability.

## Remaining failure: delivered patch omits its schema

The [realtime candidate](results/09-ft-comment-reaction-live-echo/gpt-5.6-luna-medium/ft-comment-reaction-live-echo__EchLjJU/agent.patch)
adds `db/migrate/20260922000000_create_reactions.rb` but omits the generated schema.
Patch SHA-256: `5674c7d889f3f524defec0261debd3724367dc360b896fed408e12b41c60c03b`.

Its [trajectory](results/09-ft-comment-reaction-live-echo/gpt-5.6-luna-medium/ft-comment-reaction-live-echo__EchLjJU/trajectory.json)
runs migrations locally, then explicitly restores `db/cable_schema.rb` and
`db/schema_sqlite.rb`. Later it runs a model test against that already migrated
database and restores those files again. The local database state is absent from
the captured patch. Both [native grading](results/09-ft-comment-reaction-live-echo/gpt-5.6-luna-medium/ft-comment-reaction-live-echo__EchLjJU/verifier.log)
and [fresh reconstruction](verification/09-ft-comment-reaction-live-echo/gpt-5.6-luna-medium_ft-comment-reaction-live-echo__EchLjJU/preverify.log)
stop with the migration pending. The independent verifier records
`Application baseline did not produce structured checks` with `assertion_failure: false`.
No migration or schema was added after capture to change this outcome.

Source inspection also finds the same method registered for create and destroy commit
callbacks, whole-strip replacement and missing stable entry IDs. These warrant
behavioral verification, but this attempt never reached the browser checks. Unlike
an earlier candidate, its deletion helper has an explicit block; the earlier malformed
helper diagnosis must not be carried forward as a finding about this patch.

The upstream agent receives neither Foundry nor its skills. The shipped verification
skill already requires a fresh database from the committed schema; the behavioral
reference already covers effective commit callbacks and entry-level realtime behavior.
This upstream failure does not test those instructions. Testing their effect requires
a separately labeled treatment that actually supplies them, with unchanged upstream
requirements and baseline results. Such a follow-up must not replace this score.

## Frozen inputs and accounting

The [study manifest](study.json) has SHA-256
`c5b003247a68ff572fb6369ec73f892ede9f862b5d96657faea5162261ed5c76`.
Native Le Mans 1.3.5 remains pinned at `2d0b7fb8d3b0077574dcf7b70fd4e32c8f9d6e76`;
AI-evals remains pinned at `5327efe54dd767d662ab89332f6a4285fef07bd8`.
The model is `openrouter/openai/gpt-5.6-luna#medium`, with OpenAI routing and disabled
fallback. Candidate and fresh-grading containers are network-disabled and credential-free.
The manifest, dependency inventories, image IDs, gem/skill hashes and
[ordered native commands](COMMANDS.md) preserve the inputs.

The user authorized **$7 total** across this fresh study and evidence-driven fixes/
retests. This is a cycle-wide stopping budget, not a new allowance for each rerun.
Smoke used three minutes, 15 steps and $0.25; other attempts used ten minutes,
50 steps and $0.75. Responses allowed 4,096 output tokens; shell commands allowed
60 seconds. Every native attempt followed a successful preflight and ran serially.
No automatic retries, substitutions or resets occurred. The previously authorized
provider key retained its $20 lifetime limit and no reset; that limit does not expand
the cycle budget. One in-flight request can exceed a local stopping threshold.

**Provider-confirmed spend is $0.13146371**, matching native reported cost to eight
decimal places. Provider usage increased from $0.56177733 to $0.69324104, leaving
$19.30675896 on the key. The cycle has **$6.86853629** remaining after this cohort.
See [initial accounting](initial-accounting.json) and
[the final cohort snapshot](reports/09-ft-comment-reaction-live-echo/report.json).
Any separately authorized treatment within this cycle must also subtract this spend.
No follow-up attempts are included in this report.

Pricing snapshots record $0.20/M input and $1.20/M output, plus cache and long-context
tiers. Native estimates cite RubyLLM's model registry. Interim provider counters can
lag; preflight uses the higher of native reported spend and provider usage delta.
Provider accounting confirms the total; individual costs retain native attribution.

The [input comparison](input-comparison.json) confirms all ten instructions and model
profiles match the preceding cohort. Only the two Foundry-group task digests change,
reflecting the new gem and packaged skills. The other eight task digests are unchanged.
Keep smoke outside aggregates, upstream outcomes separate from Foundry comparisons,
and any later guided treatment separate from this unchanged upstream sample.

## Verification and integrity

Fresh verification reconstructed every captured patch in a new offline container.
Completed smoke and atomic baselines retain their two pinned Vips skips. The realtime
candidate did not reach baseline test execution; its application baseline and six
browser checks are not claimed to pass.

Before freezing the measured revision, core tests passed (147 tests / 1,135 assertions),
installed-gem feature guidance passed for default/custom roots (2 / 226), installed
native workflow acceptance passed (1 / 71), RuboCop passed for 714 files, all eight
product skills and twelve examples validated, contract validation passed (10 / 142;
eight schemas and 73 cases), and strict OpenSpec validation passed for 32 items.
The active change's verification record preserves commands and earlier setup warnings.

The [artifact inventory](artifact-inventory.json) records 192 byte-identical source
files. Original native artifacts remain separate from derived verification/reports.
An exact-key scan found no provider credential in the archived content. All 2,189
previously inventoried historical evidence and repair files are unchanged, as recorded
in [the history check](history-after.json). A reporting-only JSON inspection initially
failed under US-ASCII; repeating it with the documented `RUBYOPT=-EUTF-8` succeeded.
A read-only lookup named a nonexistent `artifact-integrity.json`; the actual existing
inventory is `artifact-inventory.json`. Neither inspection changed results or inputs.

The product fix is committed; the larger fix/retest change remains active while the
scope of a Foundry-guided realtime treatment is clarified. Hosted release CI and
publishing remain outside this work.
