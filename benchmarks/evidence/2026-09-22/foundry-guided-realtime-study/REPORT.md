# Fresh paid verification of Foundry realtime guidance

The original ten-trial cohort remains **9 native passes / 1 failure**. Its upstream
realtime task did not receive Foundry. The user selected a separately labeled treatment
with the installed Foundry skills, then an evidence-driven fresh retest within the
same $7 total stopping budget. These attempts never replace the upstream score.

Both separately labeled guided attempts failed in native and independent grading.
Foundry's feature/verification entrypoints were corrected between them at
`b545b6d0c483bb63442f5bea40e14e53489e6e2f`, but the second agent still omitted the
required browser verification and submitted a broken association. **Ten-of-ten
acceptance is not achieved.** No submitted candidate was repaired or fed to another trial.

| Paid input | Native | Independent | Provider-confirmed cost |
| --- | --- | --- | --- |
| Earlier ten-trial cohort, `8188992` | 9 pass / 1 fail | 9 pass / 1 infrastructure error | $0.13146371 |
| Guided realtime G1, `8188992` | Fail | Fail in browser checks | $0.03295603 |
| Guided realtime G2, `b545b6d` | Fail | Fail in application baseline | $0.03315418 |

The cycle contains 12 paid attempts: nine passes and three native failures, with nine
independent passes, two failures and one infrastructure error. There are no invalid
protocol results in these attempts. The guided rows are separate treatments, not
additional repetitions in or replacements for the original cohort's aggregate.

## What the treatment contains

Each image starts from the same pinned Fizzy image and installs all eight product
skills through the gem's SkillInstaller. A generic paragraph appended to the original
AGENTS.md routes feature work to the feature and verification skills. Root workflow
selection is `none`. This is explicitly a skills-only treatment: the application
does not acquire the Foundry CLI, packs, a changed bundle or any runtime integration.
Unavailable architecture checks are not presented as executed checks.

Image inventories prove that all 1,763 original application files other than AGENTS.md
remain byte-identical. AGENTS.md retains its original prefix; 90 installed instruction,
receipt and configuration files are added. Ruby, Gemfile.lock and installed dependency
inventories match. The upstream instruction, setup patch, reference and six browser
requirements are byte-identical. Only application/instruction files enter the candidate
image; evaluators, references, other trials, provider credentials and the Foundry
checkout do not. Isolation probes pass for both candidates and fresh graders.

The second treatment changes only the committed skill content and resulting receipt
relative to the first. Its generic AGENTS.md addition, task files, application and
dependencies remain identical. Each task has one paid attempt; there is no automatic
retry or model/provider substitution.

## First guided attempt

- Product revision: `81889926643dc7a67757205da480769af3a9696b`.
- Native trial: `ft-comment-reaction-live-echo__uCGty1B`.
- Native and fresh result: failed, with four browser passes and two errors.
- Application baseline in both graders: 1,517 tests / 5,708 assertions, no failures
  or errors, retaining the two pinned Vips skips.
- Native duration: 300.2 seconds; 21 agent steps; 612,397 input and 8,837 output tokens,
  including 568,264 cached input tokens.
- Provider-confirmed cost: $0.03295603.
- Patch SHA-256: `eca488fea2fddb865f75c599971437e6007b0c428d2cebd76cb8a51624eac985`.

The [original trajectory](g1/results/gpt-5.6-luna-medium/ft-comment-reaction-live-echo__uCGty1B/trajectory.json)
reads both entrypoints at step 5 but does not load their realtime reference. It includes
schema changes and tests the model/controller paths. It then claims completion from
those tests and the existing suite without exercising the new browser interactions.

Both [native grading](g1/results/gpt-5.6-luna-medium/ft-comment-reaction-live-echo__uCGty1B/verifier.log)
and [fresh grading](g1/verification/gpt-5.6-luna-medium_ft-comment-reaction-live-echo__uCGty1B/verification.log)
fail when the acting viewer cannot reveal the deletion control and another viewer's
draft disappears after a remote update. These are browser `ElementNotFound` errors,
not application boot errors or assertion failures. No prohibited edits or grader
disagreement were recorded. Candidate-owned test edits remain in its patch but are
restored to trusted application tests before grading.

Source inspection finds shared viewer-specific selectors nested under differently
owned records and replacement paths that include the composer. A child also touches
its parent, which has its own update behavior. These findings support testing actual
visibility and all affected update paths; they do not justify requiring one particular
DOM design. The candidate also repeats a commit-callback filter, but creation reaches
the other viewer in this attempt. Missing creation delivery is not its measured failure.

## Shipped correction and acceptance

The feature and verification skills now put the essential realtime evidence before
implementation and completion: visible actor/viewer actions, idempotent effects,
preserved unsaved input and explicit reporting of unexecuted browser checks. The shared
reference covers nested ownership selectors and parent updates from touch/callbacks.
Detailed procedures remain in the reference. No fixture names, saved answers, evaluator
source, runtime, CLI command or configuration key entered the product skills.

The committed correction passed:

| Command | Result |
| --- | --- |
| `bundle exec rake test` | 147 tests / 1,137 assertions; no failures/errors/skips |
| `bundle exec ruby -Itest test_packaging/first_feature_test.rb` | 2 tests / 226 assertions; default/custom roots, customized guidance, selected workflow and debt preserved |
| `bundle exec rubocop` | 714 files, no offenses |
| `ruby script/validate_skills` | Six development and eight product skills validated |
| `npm run contracts:validate` | 10 tests / 142 assertions; eight schemas and 73 cases |
| `npm run spec:validate` | All 32 items passed |

The packaged lane retains intentional privacy and faulty-endpoint negative controls.
Pre-existing Packwerk/parser warnings are not hidden. A read-only attempt to locate
skill-creator inside the repository failed; the installed system skill was then read.

## Second guided attempt

- Product revision: `b545b6d0c483bb63442f5bea40e14e53489e6e2f`.
- Native trial: `ft-comment-reaction-live-echo__lRdYefy`.
- Native and fresh result: failed at the unchanged application baseline, with 1,517
  tests / 5,685 assertions, zero assertion failures, nine errors and two pinned Vips skips.
- The six browser requirements were not run because the baseline failed.
- Native duration: 516.5 seconds; 25 agent steps; 684,384 input and 8,779 output tokens,
  including 645,344 cached input tokens. No native time, step or cost limit was reported.
- Provider-confirmed cost: $0.03315418.
- Patch SHA-256: `7bcf6d4b1d5f96e446d41a0b8f98a0074f453629ddf360bbee36d9a087923cfd`.

The [second trajectory](g2/results/gpt-5.6-luna-medium/ft-comment-reaction-live-echo__lRdYefy/trajectory.json)
shows the revised feature and verification entrypoints in full at step 5. It again
does not load the shared behavioral reference or exercise the requested browser
interactions. At step 17, a `sed` command intended to remove a duplicate association
removes both copies. At step 18, a search for that association prints nothing, but
five existing model tests pass. Subsequent checks repeat those five tests and syntax
and style checks; the new view and controller calls are not exercised. The final
message claims completion despite the explicit instruction to report browser behavior
as unverified without browser evidence.

Both [native grading](g2/results/gpt-5.6-luna-medium/ft-comment-reaction-live-echo__lRdYefy/verifier.log)
and [fresh grading](g2/verification/gpt-5.6-luna-medium_ft-comment-reaction-live-echo__lRdYefy/preverify.log)
then fail nine existing endpoint tests because the rendered view calls a missing
`Comment#reactions` association. The independent grader records a behavioral baseline
failure, not an unavailable grader or prohibited edit. The patch reconstructs; there
is no grader disagreement. The other prospective realtime defects remain unmeasured
in this attempt because browser grading was not reached.

The [input comparison](g2/treatment-comparison.json) confirms the installed content
changed as intended without changing task requirements, generic AGENTS.md routing,
application code or dependencies. This rejects missing installation as the cause.
It does not establish that the new guidance caused the agent's editing error, or that
adding more instructions would cure it. No third attempt or manual repair was made.
The broader completion item remains open; the bounded paid evidence is complete.

## Offline controls and preparation

Both treatment environments run native oracle/no-op controls followed by independent
fresh verification. References pass their baseline and all six browser checks. No-op
candidates pass their baseline and fail all six browser requirements because the
requested controls do not exist. Their `ElementNotFound` errors remain explicit.
The extra protected paths cover AGENTS.md, installed skills, receipt and workflow
configuration; upstream behavioral checks are unchanged.

Five mocked preflight controls for each preparation check valid eligibility, exhausted
aggregate budget, unknown accounting, missing key and changed frozen inputs. They make
no provider requests. The retest includes the first guided attempt's known cost in
addition to the preceding ten-trial cohort, even when a mocked provider counter lags.

The first preparation build mistakenly used an image ID as a Dockerfile registry
reference. It failed before model execution. The corrected build resolves a local tag
back to the pinned image ID. Ruby style inspection found formatting issues in one-off
helpers; the reproduction helpers were normalized. The executed first preflight's
explicit zero comparison remains in its immutable source snapshot. Helper source is
retained as `.rb.source` evidence, separately from product/contributor implementation.
Selenium's blocked metadata/telemetry warnings in offline graders remain in raw logs.

Final contributor verification runs
`BUNDLE_GEMFILE=benchmarks/Gemfile bundle exec ruby -e 'Dir["benchmarks/test_lemans/*_test.rb"].sort.each { |file| require_relative file }'`:
77 tests / 621 assertions, with no failures, errors or skips. Strict OpenSpec validation
again passes all 32 items. The initial report-link check caught a reference to a browser
log that G2 never produced; it was corrected to the actual baseline log before sealing
the integrity record.

The full staged/committed whitespace check exits 2 on preserved `.patch` and `.log`
artifacts, including blank diff-context lines and Selenium output. These bytes are
retained to preserve reconstruction and evidence hashes. Authored documentation and
source snapshots receive a separate whitespace check; the full evidence check is
not described as passing.

## Accounting and interpretation

All paid attempts use native Le Mans miniswen with
`openrouter/openai/gpt-5.6-luna#medium`, OpenAI routing and disabled fallback. Le Mans
is pinned at `2d0b7fb8d3b0077574dcf7b70fd4e32c8f9d6e76`; AI-evals is pinned at
`5327efe54dd767d662ab89332f6a4285fef07bd8`. Each guided attempt has ten minutes,
50 steps, 4,096 output tokens per response, a 60-second shell timeout and a $0.75
stopping threshold. One in-flight request can exceed a local stopping threshold.

Final provider-confirmed cycle spend is **$0.19757392**: $0.13146371 for the preceding
cohort, $0.03295603 for the first guided attempt and $0.03315418 for the second.
Provider usage is $0.75935125 against the original cycle counter $0.56177733.
Native costs and provider deltas agree to eight decimal places. The cycle has
**$6.80242608 remaining**. The separately authorized key remains at its $20 lifetime
limit without reset; that limit does not enlarge the $7 cycle budget. No paid call
ran after the second guided submission.

The [first attempt's full report](g1/reports/final/report.json), [commands](g1/COMMANDS.md),
manifest, dependency inventories, source hashes, original results and derived grades
are retained separately from the [second report](g2/reports/final/report.json) and
[second command sheet](g2/COMMANDS.md). Their archives contain 53 and 52 byte-identical
source artifacts respectively and passed exact-key credential scans. All original
study and repair evidence is preserved. The final [integrity record](integrity.json)
checks the two guided inventories, 2,189 prior historical files and 192 preceding-cohort
artifacts. The active OpenSpec change remains unarchived because the broader acceptance
target is unmet.
These are exploratory observations, not a replacement ten-of-ten score or a broad
claim of future agent reliability. Hosted release CI and publishing remain separate.
