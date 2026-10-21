# Post-repair OpenRouter study — completed 2026-09-21

All ten separately authorized attempts ran once, serially, with Le Mans miniswen and
`openrouter/openai/gpt-5.6-luna#medium`, routed only to OpenAI with fallback disabled.
**Nine passed and one failed**, with native and independent graders agreeing on all ten.
There were no invalid protocols, infrastructure failures, incomplete or unstarted
attempts, automatic retries, substitutions, resets or human edits to candidates.

## Accounting

The fresh stopping budget was $7. OpenRouter usage increased from $0.12507726 to
$0.24042860: **$0.11535134 for this study**, matching native reported costs.
The previously authorized $20 lifetime-limited key had $19.75957140 remaining.
Unused study allocation is not authorization for more attempts.

Smoke had a $0.25 threshold, three minutes and 15 steps; each measured attempt had
$0.75, ten minutes and 50 steps. Responses were capped at 4,096 output tokens and
shell commands at 60 seconds. No limit was reached. Native cost estimates use the
model registry and were reconciled separately to provider accounting. Intermediate
accounting lagged; preflight used the higher cumulative amount. Pricing snapshots
are preserved in each preflight receipt, including cache and long-context rates.

Native durations, including native verification, total 925.7 seconds. Independent
grading is additional. Reported input plus output usage totals 1,378,453 tokens,
including cached input. These totals are not a controlled performance comparison.

## Results

| Task/group | Native | Independent | Cost USD | Seconds | Steps |
| --- | --- | --- | ---: | ---: | ---: |
| hello-world | pass | pass | 0.00232759 | 58.6 | 5 |
| boundary-extraction-rails | pass | pass | 0.00862854 | 49.9 | 10 |
| boundary-extraction-packs | pass | pass | 0.01434197 | 85.1 | 18 |
| boundary-extraction-foundry | pass | pass | 0.01553789 | 94.9 | 19 |
| stale-embedding-rails | pass | pass | 0.00832835 | 61.4 | 11 |
| stale-embedding-packs | pass | pass | 0.01076445 | 80.5 | 13 |
| stale-embedding-foundry | pass | pass | 0.00863124 | 62.0 | 9 |
| ar-tenant-isolation | pass | pass | 0.01925836 | 151.8 | 12 |
| aj-enqueue-after-commit | pass | pass | 0.00788527 | 94.4 | 11 |
| ft-comment-reaction-live-echo | fail | fail | 0.01964768 | 187.1 | 16 |

Smoke is excluded from measured aggregates. The six Foundry comparisons passed
all shared behavioral and authorization checks. Plain Rails, packs and Foundry each
passed 2/2. Plain Rails has no package penalty; applicable package and Foundry checks
also passed. The upstream sample passed 2/3, independently of Foundry comparisons.

## What changed relative to the first study

The [original study](../../2026-09-19/openrouter-luna-study/REPORT.md) remains unchanged:
eight passes and two failures. The new Foundry boundary-extraction candidate passed,
where its predecessor failed architecture acceptance. Both runs passed the shared
business behavior. All other task-level pass/fail outcomes stayed the same.
All ten profile digests matched the first study. Task digests matched for all eight
non-Foundry attempts; the two Foundry inputs changed with the updated gem/skills.

The new extraction trajectory provides direct evidence of diagnostic recovery:

1. The agent again created `packs/knowledge/config/foundry.yml`, initially with
   invalid `focal` and workflow settings.
2. The new misplaced-sidecar diagnostic named `packs/knowledge/foundry.yml` and
   directed workflow settings to root configuration. The agent moved the file.
3. Existing profile and namespace validation prompted further correction. The final
   sidecar declared `profile: modular` and `namespace: Knowledge`.
4. Fresh grading passed behavioral checks, Packwerk and source checks, discovering
   one configured context. The patch added no manual Rails autoload path.

This is evidence that actionable checking helped this particular attempt recover.
The trajectory does not establish diligent reading of the installed skills or an
explicit JSON assessment. Do not attribute the result solely to the skill edits.
One attempt per task/group cannot establish a general or causal improvement.

The upstream live-reaction candidate failed all six browser checks in both graders
(the earlier candidate failed three). Each new failure reached a missing-reaction
assertion after submission. Its baseline passed 1,517 tests / 5,708 assertions with
the two existing image-loader skips. The browser and application booted successfully;
Selenium's blocked metadata/statistics requests were consistent with offline grading.
The feature checks ran 6 tests / 23 assertions, with 6 failures and no errors.

Patch inspection shows whole-comment replacement broadcasts, the same callback
method registered for both create/destroy commits, request-dependent `Current.user`
markup and no successful composer reset. These are investigation leads, not a
newly verified root-cause diagnosis or repaired result. No new repair or retry ran.
Upstream candidates receive unchanged upstream requirements and no Foundry skills or
saved repair answers, so this failure does not measure the revised realtime guidance.

Tenant isolation passed 10 task tests / 66 assertions; enqueue-after-commit passed
8 / 30. Their 179-test application baselines retained the same two existing skips.

## Provenance and evidence

- Frozen Foundry revision: `13cc872e6ecd53438cf31d0fb7cb8f7034a281c7`.
- Manifest SHA-256: `9526483bb6cf9226f18095a1f6239ef58080e7937e396107c1eb8e04cf3a6b56`.
- Le Mans 1.3.5: `2d0b7fb8d3b0077574dcf7b70fd4e32c8f9d6e76`.
- Rails AI-evals: `5327efe54dd767d662ab89332f6a4285fef07bd8`.
- External frozen workspace: `/private/tmp/foundry-openrouter-luna-20260921`.
- Raw native artifacts: `results/`; fresh offline verification: `verification/`.
- Provider receipts: `preflights/` and `preflight-output/`; dependency snapshots:
  `dependencies/`; final structured report: `reports/final/report.json`.
- Frozen input, gem, skill, image and tooling hashes: `study.json` and suite inputs
  in the external workspace. `COMMANDS.md` preserves the ordered native interface.

The archive copies 159 evidence files byte-for-byte; `artifact-inventory.json`
records their SHA-256 hashes. The operational preflight lock is excluded. Original
and independently derived outcomes remain separate. Paths inside receipts identify
the original workspace. Native revision fields remain null because candidates cannot
access the Foundry checkout; the manifest supplies source provenance.

An exact-value credential scan of all 159 archived files passed before copying.
The key was loaded from the user-authorized shell configuration without executing it
or printing the key, and was supplied only to host-side preflight/model/reporting
processes. Candidate and fresh grading containers had no key and no external network.
All 152 historical files covered by the previous study's inventory were verified
unchanged (its uncopied operational lock is excluded). Historical pilots and offline
repair evidence were not modified. No product code, skills, graders or task inputs
changed during the study. Further paid trials require separate authorization.

## Repository verification after measurement

- Core: `bundle exec rake test` — 147 tests / 1,133 assertions, no failures.
- Contributor: all `benchmarks/test_lemans/*_test.rb` — 55 / 284, no failures.
- RuboCop: 699 files, no offenses. The first run could not write the sandboxed home
  cache; the completed run used `/tmp` and emitted cache-symlink warnings.
- Skills: six upstream development skills and eight product skills validated.
- Catalog: twelve executable examples validated.
- Contracts: eight schemas / 73 cases; contract tests 10 / 142.
- Strict OpenSpec: 31 items passed.
- New evidence: all 159 copied artifact hashes verified; original study unchanged.

Only evidence and benchmark documentation changed. Packaged/AI/workflow acceptance
was not rerun for this documentation-only addition; the preceding repair acceptance
remains separately attributed. Raw patches and logs retain their original whitespace.
