# Prepared local pilot restart

Status: prepared and verified; replacement model execution awaits user approval.

The first pilot used Codex 0.142.5 and stopped after its first startup was rejected for
GPT-6 Astra. It performed no coding tool calls; seventeen trials were unstarted. Preserve
[the original report](../pilot-0.142.5/REPORT.md). The original no-extra-trials constraint
means this separate eighteen-trial experiment needs approval before activation.

## Frozen experiment

- Revision: `33332c19b967fb352c399f917ccb21f43ea1b6fd`.
- CLI: official Codex 0.154.0, isolated installation; exact archive/binary hashes in runtime.json.
- Model: GPT-6 Astra; reasoning medium; workflow none.
- Tasks: boundary extraction and stale-embedding repair.
- Groups: plain Rails, Rails with packs/Packwerk, same packs application with Foundry.
- Three repetitions per task/group: eighteen serial trials.
- Limits: 600 seconds per trial; 10,800 seconds total agent execution.
- Authentication: existing local ChatGPT access only; no additional paid API calls.
- Stop on authentication/quota or startup failure; no resets, substitutions or replacement trials.
- Runtime: `/private/tmp/foundry-benchmark-runtime-0.154.0`.
- Frozen inputs: `/private/tmp/foundry-benchmark-frozen-0.154.0`.
- Proposed new output: `/private/tmp/foundry-benchmark-pilot-0.154.0` (not started).

## Verified preparation

All 36 controls passed again: eighteen reference solutions accepted and eighteen faulty
solutions rejected. All eighteen frozen starting applications passed visible acceptance
(36 test executions, 72 assertions). Actual isolation, read-only dependency, non-root,
network-disabled grading and started-process timeout probes passed. Eleven harness tests
passed. Manifest, control fingerprints, CLI probe and per-application outputs accompany
this record. These checks are not coding-agent effectiveness results.

Only authenticate and activate the existing `benchmarks/run pilot` command after approval;
do not rebuild or modify frozen inputs silently. Recheck recorded source/runtime hashes.
The runner grades independently and preserves unknown usage/cost. Attribute any results
to this exact freeze; retain the earlier failed experiment separately. Hosted CI remains
pending a repository destination; publication, deployment and live-provider evaluation
remain outside this program.
