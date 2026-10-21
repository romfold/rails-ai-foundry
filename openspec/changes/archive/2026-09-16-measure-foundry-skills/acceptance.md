# Skill benchmark preparation evidence — 2026-09-16

The six-task corpus passed all 36 controls: eighteen reference/group combinations passed
visible, withheld and applicable package checks; eighteen faulty variants failed withheld
acceptance. No faulty control was accepted merely because it failed to boot. The actual
command results and input fingerprints are recorded in benchmarks/evidence/2026-09-16/controls.json.

The contributor harness passed ten tests, including authentication/quota stop behavior,
unknown usage/cost, exact scheduling, independent grading classification, symlink rejection,
trial authentication history separation and the total timeout budget. Actual container probes
verified unavailable evaluator/repository/sibling files, read-only dependencies, non-root
execution, network-disabled grading and forced timeout cleanup. Freeze repeats these probes
against the final runtime and verifies all eighteen starting applications' visible tests.

Runtime: Ruby 3.4.10, Linux ARM64, official Codex CLI 0.142.5 archive with verified SHA-256,
Rails 8.1.3.1, SQLite gem 2.9.6, packs 0.3.0, packs-rails 0.1.0, Packwerk 3.1.0 and Foundry 1.0.0.
Exact locks, image ID, CLI binary/archive and built-gem hashes accompany the evidence.
Three separate read-only Docker volumes contain the runtime bundles; no evaluator, reference,
other trial or checkout is exposed to a candidate. Agent bridge networking is identical across
groups and is not a domain allowlist. Grading is network-disabled and credential-free.

Corrected preparation failures: Linux platforms were missing from locally resolved locks;
native gems required disposable compiler tooling; GEM_PATH needed Ruby's bundled racc;
Rack::Test's example.org host needed explicit allowance; copying existing read-only gem files
needed to preserve existing files. Slow macOS gem bind mounts were replaced with labeled
Docker runtime volumes. Provisional control runs were stopped before the final unchanged-input
run; none was a model trial. No unrelated Docker resources were pruned.

Core validation: 143 tests / 1,105 assertions; packaged acceptance six tests / 370 assertions;
optional AI eight tests / 60 assertions; workflow acceptance three tests / 39 assertions;
contracts ten tests / 142 assertions plus eight schemas / 73 cases; skills six development /
eight product; RuboCop 624 files, no offenses; strict OpenSpec 30 items passed. The packaged
upstream packs path still emits its known StringIO diagnostic; the complete suite and explicit
Foundry boundary checks pass. Hosted CI remains pending a repository destination.

Measured pilot execution and findings are pending; preparation/control results are not agent
performance results and do not justify productivity claims.

## Actual pilot outcome

Frozen revision `4f27148532c656ab3137dc9af0db7ed03e02f065` verified all eighteen starting
applications: 36 visible test executions / 72 assertions, plus repeated isolation probes.
The authorized runner attempted the first boundary-extraction/plain-Rails trial with the
installed-version pin 0.142.5. The service returned HTTP 400: GPT-6 Astra requires a newer
Codex version. No coding tools ran, no candidate files changed and no usage was reported.
The unchanged candidate independently passed visible tests and failed the required boundary
extraction. The runner stopped after 17.476 seconds; seventeen trials were never started.
This is an agent startup failure, not an authentication/quota stop or an effectiveness result.
Task 2.2 remains incomplete; no replacement trial, model substitution or usage reset occurred.

Raw events, command, stderr, empty final diffs, independent grade, full frozen input manifest,
starting-app acceptance and hardware conditions are retained under
`benchmarks/evidence/2026-09-16/pilot-0.142.5/`. Monetary cost and missing usage remain unknown.
Temporary authentication directories were removed by the runner; no credentials were copied
into the repository. Program-owned integration services were stopped before measurement.

## Evidence-driven correction and restart proposal

Official Codex 0.154.0 release notes announce GPT-6 Astra support. A separate runtime is prepared with its verified official archive hash, preserving the original runtime/freeze.
The current pin is corrected; no global CLI installation is changed. Container Codex home
uses a dedicated non-temporary mount to avoid the observed helper-alias warning. Report
rendering now explicitly identifies a rejected startup as missing implementation evidence;
its regression test brings harness coverage to eleven passing tests. These changes are
post-measurement fixes, not demonstrated improvements in coding performance. No skill text
change is justified by an attempt that never reached implementation.

A new full eighteen-trial experiment requires approval because the original plan prohibited
extra/replacement trials and comparisons must not mix CLI versions. It will use a new freeze
and output path, GPT-6 Astra medium, three repetitions per group/task, ten minutes per trial,
three hours total, existing ChatGPT access only and the same stop conditions. Original failed
results remain part of the record. Hosted CI, publication and paid provider evaluations remain
outside this local completion boundary.

The corrected runtime passed all 36 offline controls again (18 references accepted, 18 faulty
solutions rejected). Its unauthenticated version/argument probe passed without the helper
warning. Corrected preparation evidence is retained in
`benchmarks/evidence/2026-09-16/prepared-0.154.0/`; no replacement agent execution occurred.

The corrected freeze at revision `33332c19b967fb352c399f917ccb21f43ea1b6fd` passed all eighteen
starting applications (36 tests / 72 assertions) and repeated actual isolation, including a
started-process timeout. The prepared restart and complete frozen evidence are recorded in
`benchmarks/evidence/2026-09-16/prepared-0.154.0/RESTART.md`. Task 2.2 remains open.

## Authorized Spark restart outcome

The user explicitly authorized eighteen fresh trials with GPT-5.3-Codex-Spark. Frozen
revision `cd98966ab157c40670336845f0cf9c5356981f04` uses Codex 0.154.0, medium
reasoning and workflow none. All eighteen starting applications passed visible checks
(36 test executions / 72 assertions), using the unchanged 36 verified grader controls.
An initial offline freeze failed because Docker did not start the five-second timeout
probe in time. The corrected thirty-second probe confirmed process startup and termination;
this infrastructure-only adjustment did not change the 600/10,800-second model limits.

The first actual trial received HTTP 400: "The 'gpt-5.3-codex-spark' model is not supported
when using Codex with a ChatGPT account." The CLI also reported missing Spark model metadata.
The runner stopped after 24.202 seconds: one failed startup, seventeen unstarted trials,
zero coding tool calls, empty final diffs and no reported usage. The unchanged candidate
passed visible tests and failed the withheld boundary requirement. No reset, alternate
model, API credentials or additional trial was used. This is a service/model-access startup
failure, not a completed comparison or an authentication/quota stop. Task 2.2 stays open.

Evidence is preserved under `benchmarks/evidence/2026-09-16/pilot-spark-0.154.0/`.
The official model documentation lists Spark for eligible ChatGPT Pro users, but that does
not override this account/client's observed rejection. Report rendering now identifies this
rejection as missing coding evidence; twelve harness tests pass, including the no-replacement
Spark regression. This post-run reporting fix is not a measured skill improvement.


## Completed Cursor experiment and reconciliation

The user authorized Cursor and selected Composer 2.5 after isolated browser login and
account model listing. CLI `2026.09.15-d2fe57e` was pinned by official archive SHA-256
and installed-file hashes. The Linux runtime, actual model initialization, prompt, input,
skill, gem and candidate hashes are retained under
`benchmarks/evidence/2026-09-16/pilot-cursor-composer-2.5/`.

All eighteen serial trials completed at frozen revision
`fde15a8a36c15fe648f31b5aa56f002d6883232b`: 1,866.457 seconds of agent execution,
747 recorded tool calls, no malformed events, timeouts, quota/authentication stops,
protected-file edits or mid-trial interventions. Usage is preserved in Cursor's original
fields; monetary cost is unknown. All six Foundry trials read installed product skills.
The prior Codex failures remain separate; no additional Cursor trials or model probes ran.

The frozen grader recorded 13/18 passes. It wrongly rejected service delegation in trials
07 and 14, and assumed the old controller path in trial 15. After measurement, commit
`6fdac06` replaces that boundary source assertion with actual HTTP/catalog delegation,
trusted-tenant forwarding and absence of delivery SQL. All 36 original controls and nine
new delivery controls pass. Independent regrading of unchanged candidates yields 15/18:
Foundry 6/6, packs 5/6, plain Rails 4/6. Trials 01, 09 and 15 still violate the boundary;
all nine stale-embedding repairs pass. Original grades remain untouched, and every final
diff was replayed to reconstruct the exact graded source fingerprint. The fix improves
the assessment; it does not establish improved agent performance. No product-skill edit
is justified by these observations. The pilot is too small for broad productivity claims.

Commands and current results:

- `BENCHMARK_DOCKER_CONTEXT=desktop-linux benchmarks/run --runtime /private/tmp/foundry-benchmark-runtime-cursor pilot /private/tmp/foundry-benchmark-frozen-cursor-20260916 /private/tmp/foundry-benchmark-pilot-cursor-20260916 --activate-local-pilot --auth-file /private/tmp/foundry-cursor-benchmark-auth/cursor/auth.json`: eighteen completed trials.
- `BENCHMARK_DOCKER_CONTEXT=desktop-linux benchmarks/run --runtime /private/tmp/foundry-benchmark-runtime-cursor controls /private/tmp/foundry-benchmark-controls-corrected-20260916`: 45/45 controls, including rejection of deliberate faults.
- `BENCHMARK_DOCKER_CONTEXT=desktop-linux python3 /private/tmp/foundry-regrade-pilot.py`: eighteen independent grades, zero added model trials; full per-candidate grading commands are retained in evidence.
- `python3 -m unittest discover -s benchmarks/test -v`: 17 passing harness tests.
- `bundle exec rake test`: 143 tests / 1,105 assertions.
- `bundle exec rubocop`: 624 files, no offenses.
- `npm run contracts:validate`: ten tests / 142 assertions; eight schemas / 73 cases.
- `ruby script/validate_skills`: six development skills and eight product skills.
- `npm run spec:validate`: strict validation passes; repeated after reconciliation/archive.

The installed-gem, AI and workflow lanes above passed earlier in this same program; their
implementation inputs did not change during the Cursor adapter or grader work. No new
consumer runtime or dependency was introduced. One initial offline grader probe encountered
sandbox Docker-socket denial and was repeated with tool permission; it was not a model trial.
Two replayed raw agent diffs contain generated README trailing whitespace; evidence preserves
the exact bytes. All original evidence passed credential exclusion and checksum verification.
Hosted CI still awaits a repository destination. Publication remains outside this program.
