# Spark pilot evidence

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
