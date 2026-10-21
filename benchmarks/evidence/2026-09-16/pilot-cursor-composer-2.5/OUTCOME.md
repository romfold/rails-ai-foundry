# Cursor / Composer 2.5 pilot — 2026-09-16

All eighteen authorized serial trials completed using Cursor CLI `2026.09.15-d2fe57e`,
model `composer-2.5`, workflow `none`, and isolated browser authentication. The measured
Foundry revision is `fde15a8a36c15fe648f31b5aa56f002d6883232b`. Composer exposes no separate
reasoning-effort setting. Every initialization event reports Composer 2.5 and login access.

Execution took **1,866.457 seconds (31.1 minutes)**, excluding preparation and grading.
The longest trial took 191.047 seconds; all stayed inside the 600-second individual and
10,800-second total limits. There were no timeouts, startup failures, quota/authentication
stops, protected-file changes or mid-trial interventions. No replacement agent trials ran.
The earlier Astra and Spark startup failures remain separate historical experiments.

## Original and corrected grading

The immutable [original report](REPORT.md) records **13/18 passes**. Its source inspection
required a literal `Knowledge::Catalog` call in `app/controllers/documents_controller.rb`.
Trials 07 (packs) and 14 (plain Rails) correctly used delivery services calling that API
and were wrongly rejected.
Trial 15 relocated its controller into a pack, causing a missing-file grading error;
inspection also found direct model access there, so relocation alone does not merit a pass.

After all agent trials finished, the grader was changed to exercise the HTTP endpoint with
a substituted public catalog. It verifies trusted tenant forwarding, returned catalog data,
and no persistence queries outside that boundary. It accepts direct, delegated and relocated
implementations. Nine additional controls cover delegated/relocated references and an
ignored-catalog-result fault in all groups. Original grades are never overwritten.

Regrading all eighteen unchanged final candidates with grader revision
`6fdac06819da27a48453376b01cdeb83bcb037c0` produced **15/18 passes**:

| Task | Group | Original behavioral pass | Corrected behavioral pass | Package pass |
| --- | --- | ---: | ---: | ---: |
| Boundary extraction | Plain Rails | 0/3 | 1/3 | N/A |
| Boundary extraction | Packs | 1/3 | 2/3 | 3/3 |
| Boundary extraction | Foundry | 3/3 | 3/3 | 3/3 |
| Stale embedding | Plain Rails | 3/3 | 3/3 | N/A |
| Stale embedding | Packs | 3/3 | 3/3 | 3/3 |
| Stale embedding | Foundry | 3/3 | 3/3 | 3/3 |

Only trials 07 and 14 changed from fail to pass. Trials 01, 09 and 15 still bypass the
public catalog in the endpoint and fail. Trial 15 now fails a behavioral assertion rather
than a missing-file error. Package checks all pass, demonstrating that package correctness
alone does not prove the task's application-level contract.

[Regrade evidence](regrade/regrade.json) records unchanged source hashes, both outcomes,
the revised grader's source hashes and zero added agent trials. Its per-trial directories
contain independent commands and test output. [Corrected controls](corrected-controls.json)
verify all 36 original controls and nine new regressions; [regression logs](regression-controls/)
retain their actual outcomes. Six positive delivery variants pass and three ignored-result
faults fail behavior. No product skills changed after this measurement.


## Recorded effort and usage

| Task | Plain Rails median seconds | Packs median seconds | Foundry median seconds |
| --- | ---: | ---: | ---: |
| Boundary extraction | 133.0 | 132.7 | 139.8 |
| Stale embedding | 67.6 | 61.5 | 77.7 |

These medians include failed implementations; they are not time-to-correctness estimates.
The run recorded 747 distinct tool calls and no malformed event lines. All six Foundry
trials read at least one installed product skill; exact paths and shell commands are in
[audit.json](audit.json). The raw reported usage fields sum to `inputTokens: 390340`,
`outputTokens: 120563`, `cacheReadTokens: 6043505`, `cacheWriteTokens: 0`. They retain Cursor's
field meanings; no combined billable-token estimate is inferred. Monetary cost is unknown.

## Evidence and reproduction

[manifest.json](manifest.json) records task, skill, gem, runtime, CLI archive/tree, model,
prompt and starting-source hashes. [pilot.json](pilot.json) preserves each original outcome,
usage and tool event summary. Every trial directory includes the command, stderr, final
binary-capable diff, raw events compressed losslessly with gzip, and independent grades.
[SHA256.json](SHA256.json) records stored and uncompressed event hashes. No credentials,
global Cursor configuration, MCP settings or authentication history are included.

[diff-replay.json](diff-replay.json) verifies that applying each final-with-untracked diff
to its frozen starting application reconstructs the exact independently graded source hash.
Recreate inputs using `prepare` at the measured revision with the recorded runtime, verify
manifest fingerprints, apply the saved diff, then use `grade` at the desired grader revision.
`gzip -dc <trial>/events.jsonl.gz` reads the original NDJSON. Do not rerun agents implicitly.

All groups used the same host, two-CPU/1,536-MiB container limits, model-access bridge network,
network-disabled independent grading and deterministic application providers. The Apple M1 Max
host had 32 GiB RAM; Docker had two CPUs and approximately 5.8 GiB. Program-owned PostgreSQL and
Elasticsearch services were stopped before measurement; other host activity was uncontrolled.
Candidate mounts excluded the repository, evaluator, references and other candidates. Logs
show no shell attempts to access external services or evaluator material; this is an audit
of recorded calls, not a network packet capture or adversarial sandbox certification.

## Interpretation and next evidence

Only two of the six corpus tasks were measured, with three repetitions per task/group and
one account/model on one host. Every group solved stale embeddings, so this task provides
no observed Foundry advantage. Boundary results are suggestive local evidence, not a causal
estimate of skill effectiveness or a broad productivity claim. The comparison bundles
guidance and checks; it does not isolate any one skill. No speed improvement is demonstrated.

No product-skill text repair follows from these six passing Foundry attempts. The supported
fix is to the grader, with regression coverage and separately attributed regrading. A future
separately authorized study should use more varied and harder held-out tasks, including the
other four corpus tasks, and distinguish instructions from tool effects. Live model quality,
paid application providers, deployment, publication and hosted CI remain outside this run.
