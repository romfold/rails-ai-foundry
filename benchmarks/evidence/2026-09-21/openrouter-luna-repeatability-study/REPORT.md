# OpenRouter repeatability study — stopped 2026-09-21

The authorized ten-trial repeat stopped after seven attempts because independent
verification detected a protected-file edit. **Five passed, one failed, one was
invalid protocol, and three upstream tasks remain unstarted.** There are six valid
scored attempts, including smoke. No attempt reached a resource limit or failed
infrastructure setup; no native attempt was retried or repaired.

Native Le Mans reported six passes and one failure. Independent verification retained
five passes and the failure, and rejected the final native pass as invalid protocol.
Both outcomes remain preserved. The frozen preflight refused the next task; it was
not bypassed. This is a stopped study, not a completed ten-attempt comparison.

## Accounting and execution

The separately authorized stopping budget was $7, with one serial attempt per task,
using `openrouter/openai/gpt-5.6-luna#medium`, native Le Mans miniswen, OpenAI routing
only and no provider fallback. Smoke had a $0.25 threshold, three minutes and 15 steps;
the other attempts had $0.75, ten minutes and 50 steps. Responses were capped at
4,096 output tokens and shell commands at 60 seconds. No limit was reached.

Provider usage increased from $0.24042860 to $0.29992145: **$0.05949285**, matching
native reported costs. The dedicated $20 lifetime-limited key had $19.70007855
remaining. Key allowance is separate from this study's $7 authorization. Intermediate
provider accounting lagged; preflight used the higher of provider usage and native
reported cost. The reconciled snapshot is in `reports/reconciled/report.json`.
Pricing and routing snapshots remain in the preflight receipts.

Reported input plus output usage totals 584,576 tokens, including cached input.
Native durations, including native verification, total 460.3 seconds. Independent
grading is additional. These totals do not establish performance differences.
There were no model substitutions, automatic trial retries, resets or candidate edits
by the supervising agent. The three unstarted tasks incurred no model charges.

## Outcomes

| Task/group | Native | Independent | Cost USD | Seconds | Steps |
| --- | --- | --- | ---: | ---: | ---: |
| hello-world | pass | pass | 0.00230794 | 70.9 | 5 |
| boundary-extraction-rails | pass | pass | 0.00762305 | 51.0 | 10 |
| boundary-extraction-packs | pass | pass | 0.01040602 | 68.5 | 10 |
| boundary-extraction-foundry | fail | fail | 0.01650151 | 93.0 | 18 |
| stale-embedding-rails | pass | pass | 0.00869148 | 67.9 | 10 |
| stale-embedding-packs | pass | pass | 0.00648522 | 51.1 | 7 |
| stale-embedding-foundry | pass | invalid protocol | 0.00747763 | 57.9 | 9 |
| ar-tenant-isolation | unstarted | unavailable | — | — | — |
| aj-enqueue-after-commit | unstarted | unavailable | — | — | — |
| ft-comment-reaction-live-echo | unstarted | unavailable | — | — | — |

Smoke is excluded from the Foundry aggregate: four credited passes, one architecture
failure and one invalid attempt across six comparisons. Plain Rails and packs each
passed 2/2; Foundry has one failure and one invalid attempt. All six restored shared
behavioral checks passed, but that does not remove architecture or protocol gates.
Plain Rails receives no package penalty. There are no upstream sample results.
There are zero infrastructure errors and zero resource-limited incomplete attempts.

## Confirmed findings

### Knowledge package privacy was not enabled

The boundary-extraction Foundry candidate preserved tenant-scoped behavior, delegated
to the public Catalog API and placed a valid architecture sidecar at the pack root.
Its `package.yml` declared dependencies and `public_path: app/public` but omitted
`enforce_privacy: true`. Both graders reported:

```text
Privacy enforcement missing: packs/knowledge/package.yml
```

Visible tests passed 2 / 4 and acceptance passed 3 / 14. Packwerk validation/checking
and `foundry check --sources` passed, discovering one context. Those commands did
not establish that the requested privacy policy was enabled. The explicit task
architecture check correctly withheld credit. The original patch remains unchanged:
SHA-256 `9f6ef49e9fe5fe04054f891f49dba6c18f37abd6887f0cee3d5daa122aab02e8`.

### Correct behavior did not excuse a protected test edit

The Foundry stale-embedding candidate added two regression tests directly to
`test/visible_test.rb`. It did not remove assertions, skip checks or weaken existing
tests. However, the frozen instructions explicitly prohibit changing visible tests;
new focused tests must go in an unprotected file. Fresh verification recorded the
protected edit, restored trusted tests, and passed 2 / 4 visible and 3 / 33 acceptance
checks, plus architecture checks. Its status remains **invalid protocol** despite
the diagnostic passing behavior and native reward of 1.0.

Patch SHA-256: `1e45e2b56be77b7d4488912779a4b48b5ca7e6c0595f5c960b1f55223af99f30`.
The next preflight's `failure.json` records `Previous attempt not independently verified`.
That wording reflects rejection of invalid predecessors, not absence of a completed
grader. The frozen rule accepts only passed, failed or incomplete predecessors.
No reservation or native run was created for the next task. The protected-file rule
was not relaxed after seeing the result, and neither patch nor score was rewritten.

## Interpretation and provenance

This repeats the preceding study's agent-visible inputs. All ten task and profile
digests match; all 137 shipped gem payload files match. `input-comparison.json`
records the comparison. The intervening offline repair changed contributor evidence
and repair fixtures, not the task inputs or shipped skills. It could not teach this
agent the saved repair. The upstream live-reaction task did not run in this study.

The preceding paid study remains [nine passes / one failure](../openrouter-luna-study/REPORT.md).
Its [offline realtime repair](../second-study-repair/REPORT.md) remains separately
attributed human-assisted regression evidence. This repeat demonstrates variation
and the value of independent protocol checking, not a causal skill regression or
improvement. A single attempt per task/group does not support general productivity claims.

- Frozen Foundry revision: `b40528965c0360bd15f2702652f731fa29d1baec`.
- Manifest SHA-256: `2b32a3052b6127ea028c882c40cf92e68a312e559c154dd3f3448b13b17307ea`.
- Le Mans 1.3.5: `2d0b7fb8d3b0077574dcf7b70fd4e32c8f9d6e76`.
- Rails AI-evals: `5327efe54dd767d662ab89332f6a4285fef07bd8`.
- Frozen workspace: `/private/tmp/foundry-openrouter-luna-20260921-r3-v2`.
- Execution commands: `COMMANDS.md`; only attempts 00 through 06 executed.
- Native patches, trajectories and scores: `results/`; fresh grades: `verification/`.
- Inputs, image, gem and skill hashes: `study.json`; resolved dependencies: `dependencies/`.
- Receipts and rejected preflight: `preflights/` and `preflight-output/`.

The archive preserves 132 source artifacts byte-for-byte; `artifact-inventory.json`
records their hashes. The mutable operational preflight lock is excluded. Native and
derived results stay separate, and receipt paths identify the original workspace.
An exact-value scan found no authorized key in any copied artifact. Only host-side
model/preflight/report processes received the key; fresh graders were credential-free
and network-disabled. Historical before/after inventories verify 1,258 files unchanged.

Initial preparation failed while Docker Desktop was stopped. After starting Docker,
a fresh workspace was prepared successfully; the earlier failed workspace was retained
at `/private/tmp/foundry-openrouter-luna-20260921-r3`. No paid attempt ran during that
preparation failure. A local report-reading command initially lacked UTF-8 settings;
its corrected invocation succeeded without changing evidence or starting an agent.

## Repository verification after measurement

- Contributor tests: 61 tests / 316 assertions, no failures or errors.
- RuboCop: 704 files, no offenses.
- Skills: six upstream development and eight product skills validated.
- Catalog: twelve executable examples validated. The initial command omitted `.rb`
  and failed with `LoadError`; `ruby script/validate_examples.rb` passed.
- Contracts: eight schemas / 73 cases; tests 10 / 142, no failures.
- Strict OpenSpec: 31 items passed.
- Core: `bundle exec rake test` — 147 tests / 1,133 assertions, no failures or errors.
- All 132 archived artifact hashes verified; historical evidence remains unchanged.

Only evidence and benchmark documentation changed. Packaged, AI and workflow lanes
were not repeated for this documentation-only addition. No product code, skill,
grader or task policy was changed. No further paid execution is scheduled; resuming
past this stop would require an explicit decision about the protocol gate rather
than an automatic retry or unused-budget assumption.
