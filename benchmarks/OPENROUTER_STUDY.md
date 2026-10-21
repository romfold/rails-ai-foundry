# First OpenRouter study

This is the separately authorized ten-attempt GPT-5.6 Luna study. It does not restart
or replace historical Cursor measurements. Native Le Mans remains the only agent runner.

The authorized study is complete. See the [results and evidence](evidence/2026-09-19/openrouter-luna-study/REPORT.md).
Commands below document its procedure; they do not authorize another run.

## Key and limits

The user authorized the existing key with a **$20 lifetime limit** on 2026-09-19,
superseding the original $8 key requirement. Keep no periodic reset or automatic
replenishment. The study allocation remains $7; the higher key limit does not authorize
additional spending or attempts. Use this key only for this study while it runs.
Preflight checks limit, usage and remaining allowance; automatic replenishment settings
must be checked in the OpenRouter account UI by the owner.

In the same macOS zsh terminal that will launch the benchmark:

```zsh
read -rs 'OPENROUTER_API_KEY?OpenRouter API key: '
export OPENROUTER_API_KEY
printf '\n'
```

The hidden prompt keeps the value out of shell history. Do not paste it into chat,
Git, command arguments, study files or container settings. A terminal's exported
variable does not automatically become available to an already-running Codex process.
The account receipt includes a one-way key fingerprint to reject accidental key changes;
it never includes the key or its provider label. Run `unset OPENROUTER_API_KEY` afterward.

## Prepare once

From the repository root, using Ruby 3.4.10, Node 20.19.0 and local Docker:

```sh
export BUNDLE_GEMFILE="$PWD/benchmarks/Gemfile"
export RUBYOPT=-EUTF-8
export DOCKER_CONTEXT=desktop-linux
bundle install
benchmarks/suite prepare-study /tmp/foundry-openrouter-study
```

Use a new absolute directory. Preparation builds the selected images and records their
resolved dependencies; it makes no inference calls. `BENCHMARK_UPSTREAM_CHECKOUT` may
point to an existing checkout at the exact AI-evals pin to avoid another source fetch.
Preparation checks effective per-task limits and freezes contributor code, application
inputs, gem/skill hashes, model/profile identity and image IDs. Do not edit frozen files
or update contributor code before completing the study.

The generated `COMMANDS.md` lists the ten ordered blocks. Each block first runs
`study-preflight`, then the native Le Mans command only if preflight succeeds, then
independent replay and a new study report. Run each block once, serially. Do not use
Le Mans `--resume` or raise attempts/concurrency. The profile selects
`openrouter/openai/gpt-5.6-luna#medium`; the command pins OpenAI routing with fallbacks
disabled through `LEMANS_PROVIDER_ORDER=openai`. No key enters candidate containers.

## Matrix and stops

| Stage | Tasks | Limits |
| --- | --- | --- |
| Smoke | hello-world | $0.25, 3 minutes, 15 steps |
| Foundry | boundary-extraction and stale-embedding, each in rails/packs/foundry | $0.75 each, 10 minutes, 50 steps |
| Upstream | ar-tenant-isolation, aj-enqueue-after-commit, ft-comment-reaction-live-echo | $0.75 each, 10 minutes, 50 steps |

All attempts cap response output at 4,096 tokens and shell commands at 60 seconds.
The nine measured attempts and smoke allocate $7. Provider requests can overshoot a
Le Mans per-attempt limit because it checks between requests. The $20 provider-key limit
is not a $10 study spending ceiling; never treat the local thresholds as
exact billing ceilings. Preflight reads current pricing and requires sufficient remaining
allowance, including $1 headroom. Unknown cost, authentication/quota errors, changed keys,
changed inputs, unfinished predecessors or failed smoke verification stop progress.

In newly prepared studies, an independently diagnosed protected-file violation keeps
its invalid score and cost but permits the next independent task. This requires a
completed native attempt, completed task-phase verification with an explicit underlying
pass/fail result, recorded protected paths, intact evidence and known accounting.
Infrastructure errors, unknown accounting and grader disagreements still stop.
Old frozen studies retain their original rules; do not resume them with changed tooling.

For Foundry comparison tasks, new regression coverage belongs in a new test file.
Existing visible tests and test helpers remain protected even when an edit only adds
assertions. Inspect the final diff before submission. All three groups receive the
same protocol clarification; upstream task instructions stay unchanged.

Preflight records a create-only reservation. A successful preflight must immediately
precede its native command in that terminal; never reuse it later or remove a reservation
to retry. If a preflight fails before reserving an attempt, fix the prerequisite and use a
new preflight-output directory; no paid retry is authorized. Stop after any interrupted
or ambiguous launch and inspect the evidence before further work.

Le Mans may mark a resource-limited attempt as scored. Our live report preserves that
native result and labels the attempt incomplete; a diagnostic grade of its partial patch
does not promote it to a completed success. Ordinary completed behavioral failures are
valid measurements. Upstream and Foundry groups, package checks, and smoke remain separate.

## Read results

```sh
benchmarks/suite study-report /tmp/foundry-openrouter-study /tmp/foundry-openrouter-summary
```

Reporting does not run agents. If the key is available it reads provider accounting;
otherwise provider spend remains unknown. `report.json` contains individual native
results, usage/cost source, independent grades, hashes, group counts and provider usage
delta. Existing raw outputs and reports are never overwritten. Missing artifacts,
duplicates and protocol violations cannot receive credit. One attempt per task/group
is exploratory evidence, not a leaderboard reproduction or a causal productivity claim.
