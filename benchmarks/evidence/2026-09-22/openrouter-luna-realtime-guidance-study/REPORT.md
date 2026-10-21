# Paid study after realtime guidance — 2026-09-22

Ten fresh, separately authorized GPT-5.6 Luna medium attempts ran at revision
`545e12f2cbfe6da095808c74ffbd29c5ec26229f`. The independently recorded outcome is
**8 passes, 1 architecture-policy failure and 1 verification infrastructure error**.
Native Le Mans reports eight passes and two failures. The second failure could not
produce an independent task grade because the candidate stopped before baseline
test reporting. It is not a measured browser-test failure or a passing candidate.

All ten attempts ran once, serially. No candidate was repaired, no trial retried,
and no model or provider substituted. The earlier paid study's **9 passes / 1 failure**
and all offline repairs remain unchanged. This study is complete; no further paid
attempts are authorized by this report.

## Outcomes

Smoke passes separately. The Foundry comparison has five passes and one architecture
failure; all six candidates pass their shared behavioral checks. Upstream Rails has
two passes and one unavailable independent grade. Plain Rails and packs each pass
both comparison tasks; Foundry passes stale embedding and fails the requested profile.

| Task | Native / independent | Reported USD | Steps | Input + output tokens | Native seconds |
| --- | --- | ---: | ---: | ---: | ---: |
| hello-world (smoke) | pass / pass | 0.00233201 | 5 | 12,705 | 72.9 |
| boundary-extraction-rails | pass / pass | 0.00729868 | 10 | 62,736 | 46.4 |
| boundary-extraction-packs | pass / pass | 0.02054908 | 23 | 311,703 | 119.9 |
| boundary-extraction-foundry | fail / fail | 0.01518286 | 17 | 221,001 | 83.8 |
| stale-embedding-rails | pass / pass | 0.01089332 | 11 | 98,011 | 66.4 |
| stale-embedding-packs | pass / pass | 0.00847593 | 11 | 70,940 | 70.4 |
| stale-embedding-foundry | pass / pass | 0.01216647 | 14 | 131,431 | 74.3 |
| ar-tenant-isolation | pass / pass | 0.02294629 | 16 | 361,055 | 167.0 |
| aj-enqueue-after-commit | pass / pass | 0.01174374 | 18 | 162,549 | 118.7 |
| ft-comment-reaction-live-echo | fail / infrastructure error | 0.02749608 | 20 | 469,271 | 133.8 |

There are ten attempted native trials, nine completed independent task assessments,
zero recorded protected-file violations, zero completed-grade disagreements, no
resource-limited attempts and no unstarted trials. The missing independent grade
remains an infrastructure error; it must not be collapsed into grader agreement.
Native durations include setup and native grading, but exclude independent replay.
Token totals include repeated/cached input; raw usage and cost sources are retained.

## Confirmed unsuccessful candidates

### Requested modular profile was not installed

The [boundary patch](results/03-boundary-extraction-foundry/gpt-5.6-luna-medium/boundary-extraction-foundry__NrOpxZ1/agent.patch)
correctly places `packs/knowledge/foundry.yml`, with namespace `Knowledge`, but sets
`profile: rails_native`. The task explicitly requires `modular`. Both graders report
`Modular Knowledge missing`. Endpoint/authorization tests, Packwerk and the generic
Foundry structural check pass. Valid configuration is not proof of fulfilling the
task's selected architecture; this is a requirement mismatch, not failed loading.

Patch SHA-256: `58f0e44c60d33a64946406bdc1733fd3e6eeacf49bd12017fddb3cbba6b8cd92`.
See [the independent architecture result](verification/03-boundary-extraction-foundry/gpt-5.6-luna-medium_boundary-extraction-foundry__NrOpxZ1/foundry.json).

### Pending migration prevents live-reaction grading

The [live-reaction patch](results/09-ft-comment-reaction-live-echo/gpt-5.6-luna-medium/ft-comment-reaction-live-echo__4fHHAIO/agent.patch)
adds `db/migrate/20260921000000_create_reactions.rb` without a corresponding schema
update. Both [native grading](results/09-ft-comment-reaction-live-echo/gpt-5.6-luna-medium/ft-comment-reaction-live-echo__4fHHAIO/verifier.log)
and [fresh baseline execution](verification/09-ft-comment-reaction-live-echo/gpt-5.6-luna-medium_ft-comment-reaction-live-echo__4fHHAIO/preverify.log)
stop with that migration pending. The fresh verifier consequently reports
`Application baseline did not produce structured checks`. None of the six upstream
browser requirements ran. No migration was applied after capture to manufacture a
new grade; the original requirements and grading procedure remain unchanged.

Patch SHA-256: `cb62fd83a4d7964fc49722bf047f4372461b0a5946cc9ae8114de81f7078edd3`.
Source inspection also finds the same method registered for create and destroy
commit callbacks, whole-strip replacement and no stable entry IDs. Those are
follow-up concerns; this trial did not reach behavioral evidence for them.

## Frozen conditions and accounting

Native Le Mans miniswen used `openrouter/openai/gpt-5.6-luna#medium`, OpenAI routing
and disabled provider fallback. Le Mans remains 1.3.5 at
`2d0b7fb8d3b0077574dcf7b70fd4e32c8f9d6e76`; AI-evals remains at
`5327efe54dd767d662ab89332f6a4285fef07bd8`. Managed Ruby 3.4.10 prepared the study.
The [manifest](study.json), [ordered commands](COMMANDS.md), image IDs, resolved
dependencies, installed-gem and skill hashes retain the exact inputs. Manifest SHA-256:
`b2531150d04fe69d5e3f7bdad18f1765b36f6908977597c614eb9275c0364759`.

The user authorized ten attempts and a fresh $7 stopping budget. Smoke used three
minutes, 15 steps and $0.25; each measured trial used ten minutes, 50 steps and $0.75.
Responses were capped at 4,096 output tokens and shell commands at 60 seconds.
Preflight ran immediately before each native command. The existing separately
authorized key retained its $20 lifetime limit and no reset; that limit did not
expand this study's budget. Model calls ran on the host. Candidates and fresh graders
were network-disabled and credential-free.

**Provider-confirmed spend is $0.13908446**, matching native reported cost at eight
decimal places. The provider usage counter increased from $0.42269287 to $0.56177733;
remaining allowance was $19.43822267. The separate
[final accounting snapshot](reports/final-accounting-confirmed/report.json) preserves
this confirmation. Earlier lagging snapshots remain intact. Provider usage confirms
the total; per-attempt figures in the table retain their native cost-source attribution.

Preflight snapshots record $0.20/M input and $1.20/M output, plus cache/tier pricing.
Native estimates cite RubyLLM's model registry. Interim provider counters lagged;
budget checks used the higher of native reported spend and provider usage delta.
No limit was reached. Local thresholds are stopping checks, not exact billing caps.

## What this run measures

The [input comparison](input-comparison.json) confirms all ten profile hashes match
the preceding study. Only the two Foundry-group task hashes changed, reflecting the
new gem and skills. Plain Rails, packs, smoke and upstream task hashes are unchanged.

The upstream live-reaction agent received neither Foundry skills nor the repaired
candidate. Repeating it therefore does **not** measure whether the new realtime
guidance helps. The Foundry comparison tasks exercise boundary extraction and stale
embeddings, not realtime delivery. One attempt per cell cannot establish causal
improvement, regression, future 10/10 reliability or broad productivity effects.
A direct test of realtime guidance would need a separately designed comparison
that actually supplies that guidance while retaining an unchanged upstream baseline.

## Evidence and repository checks

Original results, trajectories and patches are separate from derived verification
and reports. The artifact inventory records byte-identical copies and an exact-key
credential scan. Historical evidence, prior repairs and product skills match their
pre-run inventory of **1,877 files**. No product code, skill, benchmark requirement,
grader, configuration schema or Foundry CLI changed during this run.

Completed upstream baselines retain the two pinned Vips NIFTI/RAW skips. Smoke and
the two atomic tasks each pass the 179-test / 553-assertion baseline. The realtime
candidate never reached baseline test execution; the 1,517-test Fizzy suite is not
claimed to pass for this candidate.

| Command | Result |
| --- | --- |
| `BUNDLE_GEMFILE=benchmarks/Gemfile bundle exec ruby -Ibenchmarks/test_lemans -e 'Dir["benchmarks/test_lemans/*_test.rb"].sort.each { \|path\| require_relative path }'` | 70 tests / 579 assertions, passed before paid execution |
| `bundle exec rake test` | 147 tests / 1,134 assertions, passed |
| `bundle exec rubocop` | 710 files, no offenses |
| `ruby script/validate_skills` | Six development and eight product skills valid |
| `bundle exec ruby script/validate_examples.rb` | Twelve examples valid |
| `npm run contracts:validate` | Ten tests / 142 assertions; eight schemas and 73 cases valid |
| `npm run spec:validate` | 31 items passed, zero failed |
| Frozen-input, archive-hash, exact-key and historical-integrity checks | Passed |

This evidence-only change does not alter executable behavior. Installed-gem default/
custom-root guidance acceptance and offline repair controls were accepted at the
measured revision in the [preceding repair report](../../2026-09-21/guidance-study-repair/REPORT.md);
those larger lanes were not repeated for this report addition.

Read-only setup searches named several nonexistent paths; a process-status probe
was denied by the local sandbox. These inspection errors did not change study
inputs or launch extra trials. The live-reaction log lookup also confirmed no
native `checks.json` was produced. Raw patch whitespace and original tool warnings
remain preserved; archived evidence is not autoformatted. Hosted release CI and
publishing remain separate.
