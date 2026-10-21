# Reviewed AI study preparation: offline acceptance

Accepted locally on 2026-09-23. **14/14 controls; zero coding-agent trials.**

| Variant | Upstream packs | Installed Foundry |
| --- | --- | --- |
| reference | passed | passed |
| delegated | passed | passed |
| bypass_approval | failed | failed |
| ignore_revision | failed | failed |
| stale_generation | failed | failed |
| duplicate_execution | failed | failed |
| noop | failed | failed |

All expected outcomes matched. Total independent grading time: 560.5 seconds.
Every valid implementation passed baseline 11 tests / 54 assertions, HTTP 6 / 36,
durability 3 / 10, browser 1 / 6, and Packwerk. Treatment source/prompt checks passed.
The four injected faults per group failed assertions with zero test errors; empty
patches failed with the expected unimplemented services. No final infrastructure errors.

## Frozen conditions

Linux arm64, Ruby 3.4.10, PostgreSQL 17.11 (Debian 17.11-0+deb13u1), Chromium and
ChromeDriver 153.0.8010.52, Rails 8.1.3.1, RubyLLM 1.16.0 and Solid Queue 1.7.0.
Independent grader: two CPU cores, 2 GiB memory, 256 processes, ten-minute deadline,
read-only evaluator mount, no external network/capabilities/Docker socket, fresh database.
Common resolved application dependency versions match. Only Foundry and its benchmark
library dependency differ in the resolved bundles. Full locks and image IDs are retained.
An additional read-only probe verified no Foundry gem/cache files in the upstream image.

Tested gem SHA-256: `6d846886ac59db64e155bb96b31ea23a86f83edb672838be73d6408a788c75b7`.
`manifest.json` records prepared file and skill hashes; `report.json` freezes the final
workspace including image records. `controls/` retains independent result/check/input
JSON and full verifier stdout. The guide matched the canonical application before replay.
Final documentation reconciliation may change archive bytes: regenerate and revalidate
inputs before any separately authorized experiment. No effectiveness inference follows.

## Reproduction and attribution

Follow `benchmarks/reviewed-ai/README.md`. Preparation, image construction, dependency
capture, isolation and `reviewed-study-controls` were run in separate disposable output
directories. Le Mans remains the only future agent runner; these grades replay patches.
Contributor unit acceptance: 82 tests / 654 assertions, all passing. Freeze controls
reject modified and additional inputs; valid controls and faulty controls are separate.

Initial v1/v2 image builds failed dependency resolution; v3 grader failed non-root log
access; v4 hit a missing favicon in browser acceptance; v5 found absent protected
directories in the upstream group. `preparation-failures/` preserves probe results and
v5 results separately. The final v6 matrix corrected these infrastructure issues.
The archived v4 stdout has trailing whitespace normalized; test outcomes are unchanged.
Those failures are not agent outcomes. Historical studies and their hashes are unchanged.

## Limits

This prepares the proposed six serial twenty-minute trials. Agent, model, versions,
access and spend limits require separate approval. Usage/cost are null/unknown.
The treatment includes a worked public tutorial; the task adapts its architecture to
SupportDesk, and private assertions are independently authored. This is a combined
guidance/tooling comparison, not isolated skill causality or independent-user research.
Hosted CI remains unexecuted pending a repository destination.
