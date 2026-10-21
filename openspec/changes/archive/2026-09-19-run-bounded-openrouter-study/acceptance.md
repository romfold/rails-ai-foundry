# Implementation readiness — 2026-09-19

Contributor implementation is verified. Paid execution remains unstarted because
`OPENROUTER_API_KEY` is unavailable to the executing process. No inference requests
were made. The change remains active; execution and final accounting tasks are pending.

## Frozen study

- Source revision: `cdc4bce24bc83baa02a59a8df2613be78075bd34`.
- Workspace: `/private/tmp/foundry-openrouter-luna-20260919-v2`.
- Manifest SHA-256: `a793f1bfa4b9a3d61bc0a1279e1060629568a7268bcf4f94e6ca2eab0cf2c567`.
- Native commands: `COMMANDS.md` in that workspace.
- Readiness report: `reports/readiness/report.json` and `REPORT.md`.
- Missing-key evidence: `readiness/missing-key/failure.json`.
- Earlier preparation remains preserved at `/private/tmp/foundry-openrouter-luna-20260919`;
  use the v2 workspace for the final implementation.

Preparation successfully built the gem, prepared the selected Docker images and
resolved dependencies, checked effective profiles, and froze all ten tasks. Readiness
preflight validated frozen inputs, then exited 1 for the missing key without an attempt
reservation. Reporting exited 0 with ten unstarted attempts: one smoke, six Foundry and
three upstream. No native costs exist; provider usage is unknown, not verified zero.

## Verification

- Contributor suite: 52 tests, 275 assertions, zero failures/errors/skips.
- Disposable Docker integrity acceptance: 7 tests, 21 assertions, zero failures.
  Evidence: `/tmp/foundry-openrouter-integrity-20260919`.
- Core suite: 143 tests, 1,108 assertions, zero failures.
- Full RuboCop: 694 files without offenses; final result-shape changes also passed
  focused RuboCop with caching disabled because the default cache was not writable.
- Skills: six development workflows and eight product skills validated.
- Contracts: 10 tests, 142 assertions; eight schemas and 73 cases validated.
- Strict OpenSpec validation: 32 items passed.

The malformed-artifact regression initially attempted to overwrite a create-only test
fixture and failed; the fixture was corrected and the complete contributor suite rerun.
Style findings were corrected before the final freeze.

## Next authorized action

In the terminal holding the dedicated $8 lifetime-limited key, follow
`benchmarks/OPENROUTER_STUDY.md` and the v2 ordered command sheet. The smoke must pass
native and fresh independent verification before a measured attempt can start. Never
paste credentials into chat or files. Do not archive this change until actual outcomes
and provider accounting are recorded, including any trials left unstarted by stop rules.

## Completed execution — 2026-09-19

The user explicitly approved the existing $20 lifetime-limited key, superseding only
the earlier $8 key requirement. After tests and a new freeze at revision
`037f32115715026c6f550612f7dae7efda2bac56`, all ten attempts ran serially in
`/private/tmp/foundry-openrouter-luna-20260919-v3`. All received fresh independent
verification. Eight passed and two failed; no disagreement, infrastructure/protocol
failure, resource stop, retries or unstarted attempts occurred.

Provider usage and native estimates agree at $0.12507726. Original and derived
artifacts, per-task outcomes and failure details are preserved under
`benchmarks/evidence/2026-09-19/openrouter-luna-study/`. The initial missing-key and
key-limit refusals remain preserved in the earlier v2 workspace. The original
readiness record above describes the earlier state and is not the final outcome.

The key-limit change passed the 52-test/275-assertion contributor suite and focused
RuboCop. Strict OpenSpec validation passed 32 items. The live artifacts passed an
exact-key scan across 153 files without disclosure. No product skills or applications
were changed. Historical pilot evidence remains unchanged.
