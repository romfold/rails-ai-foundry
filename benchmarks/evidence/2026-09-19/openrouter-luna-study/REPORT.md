# First OpenRouter study — completed 2026-09-19

All ten authorized attempts ran once, serially, using pinned Le Mans miniswen and
`openrouter/openai/gpt-5.6-luna#medium`, routed only to OpenAI without fallback.
There were **eight passes and two measured failures**, with zero native/independent
disagreements, invalid protocols, infrastructure failures, incomplete or unstarted attempts.
No automatic retries, additional trials, model substitutions or resets occurred.

## Accounting and limits

OpenRouter usage rose from zero to **$0.12507726**, matching native reported costs
exactly. The final key allowance was $19.87492274. The user explicitly approved the
existing $20 lifetime-limited key in place of the original $8 key; the $7 study
allocation, per-attempt limits and original $10 budget did not increase.

Smoke used a $0.25 limit, three minutes and 15 steps. Each measured attempt used
$0.75, ten minutes and 50 steps; all used 4,096 maximum response tokens and a
60-second shell timeout. No resource limit was reached. Native attempt durations,
including their verification, total 902.2 seconds; independent grading is additional.
Total reported input plus output tokens: 1,684,442, including cached input usage.
Costs are native model-registry estimates, separately reconciled to provider usage.
Intermediate provider snapshots lagged; preflight used the higher cumulative figure.

## Outcomes

| Task/group | Native | Independent | Cost USD | Seconds | Steps |
| --- | --- | --- | ---: | ---: | ---: |
| hello-world | pass | passed | 0.00227623 | 58.1 | 5 |
| boundary-extraction-rails | pass | passed | 0.00807425 | 42.0 | 8 |
| boundary-extraction-packs | pass | passed | 0.01485368 | 72.8 | 17 |
| boundary-extraction-foundry | fail | failed | 0.01836312 | 98.3 | 24 |
| stale-embedding-rails | pass | passed | 0.00837559 | 49.4 | 9 |
| stale-embedding-packs | pass | passed | 0.00910383 | 50.2 | 10 |
| stale-embedding-foundry | pass | passed | 0.00769368 | 49.2 | 8 |
| ar-tenant-isolation | pass | passed | 0.01954742 | 160.0 | 16 |
| aj-enqueue-after-commit | pass | passed | 0.01205268 | 98.2 | 15 |
| ft-comment-reaction-live-echo | fail | failed | 0.02473678 | 224.0 | 17 |

Smoke is outside measured aggregates. The six Foundry comparisons produced 5/6 full
passes: plain Rails 2/2, packs 2/2, Foundry 1/2. **All six passed shared behavioral
and authorization tests**. The failed Foundry boundary extraction passed Packwerk
but omitted the required modular Knowledge configuration. Foundry source checking
reported zero configured contexts without failing; the independent architecture
policy caught the omission. This is a concrete guidance/checking gap to investigate,
not evidence of a general productivity disadvantage from a one-attempt sample.

The upstream sample produced 2/3 full passes. Tenant isolation passed ten task tests;
enqueue-after-commit passed eight. The live-reaction candidate passed three of six
browser checks but failed to show expected reactions to watching users, the reacting
user, and a viewer editing a comment. These are measured assertion failures, not
browser startup failures. Browser setup logged unsuccessful external metadata/statistics
requests under the intended network-disabled environment; local browsers ran.
The unchanged upstream image baseline retained its two recorded image-loader skips.

## Provenance and replay

- Frozen Foundry revision: `037f32115715026c6f550612f7dae7efda2bac56`.
- Manifest SHA-256: `57f4ec662120aba7464edf9e21aea923a1fa51e5f28afdc7847ebda9f6716247`.
- Le Mans 1.3.5: `2d0b7fb8d3b0077574dcf7b70fd4e32c8f9d6e76`.
- Rails AI-evals: `5327efe54dd767d662ab89332f6a4285fef07bd8`.
- External frozen application/image/dependency workspace:
  `/private/tmp/foundry-openrouter-luna-20260919-v3`.
- Raw native evidence: `results/`; fresh independent evidence: `verification/`.
- Sanitized accounting receipts: `preflights/`; final structured report:
  `reports/final/report.json`; file hashes: `artifact-inventory.json`.

This evidence directory copies original artifacts byte-for-byte. Paths inside receipts
continue to identify the original workspace. Frozen application inputs and resolved
dependency/image receipts remain in that external workspace; the complete file hashes
are in `study.json`. Native revision fields are null because candidate workspaces exclude
the Foundry checkout; the study manifest supplies source provenance.

The key was read from the explicitly authorized shell configuration into host process
environments, never printed or passed to candidate/grader containers. An exact-value
scan of 153 persisted artifact files found no key. The inventory includes the empty
preflight lock file; that runtime lock is not copied into this evidence directory.
Historical Cursor and Codex pilot evidence remains unchanged. No fixes to product
skills or applications were made during or after these frozen trials. Future live
studies need separate authorization; this is exploratory local evidence, not a Rails
leaderboard reproduction or a broad causal effectiveness claim.
