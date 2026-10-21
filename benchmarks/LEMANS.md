# Le Mans contributor workflow

The replacement is verified by the [local acceptance record](evidence/2026-09-19/lemans-upstream-controls/REPORT.md).
The custom execution runner is retired. No live agent run is authorized by this document.

The contributor bundle pins Le Mans **1.3.5**, commit
`2d0b7fb8d3b0077574dcf7b70fd4e32c8f9d6e76`. The upstream suite pins
Rails AI-evals `5327efe54dd767d662ab89332f6a4285fef07bd8`: 21 atomic tasks,
20 feature tasks and one separately reported smoke task. Requirements, solutions,
verification files and notices are exported from that commit; historical runs and
Git history are excluded. Nothing is installed into Foundry's production bundle.

## Preparation

Use managed Ruby 3.4.10 and a disposable local Docker engine. Initial image and
dependency preparation requires network access. Use new absolute output paths
outside this checkout. Existing outputs are never overwritten.

```sh
export BUNDLE_GEMFILE="$PWD/benchmarks/Gemfile"
export RUBYOPT=-EUTF-8
export DOCKER_CONTEXT=desktop-linux # omit on native Linux
bundle install
bundle exec ruby -e 'Dir["benchmarks/test_lemans/*_test.rb"].sort.each { |file| require_relative file }'

benchmarks/suite prepare-upstream /tmp/upstream-suite
benchmarks/suite images /tmp/upstream-suite
benchmarks/suite dependencies /tmp/upstream-suite /tmp/upstream-dependencies

benchmarks/suite prepare-foundry /tmp/foundry-suite
benchmarks/suite images /tmp/foundry-suite
benchmarks/suite dependencies /tmp/foundry-suite /tmp/foundry-dependencies
benchmarks/suite prepare-controls /tmp/foundry-suite /tmp/foundry-controls
benchmarks/suite isolation /tmp/foundry-suite /tmp/foundry-isolation
```

`prepare-upstream OUTPUT PINNED_CHECKOUT` can reuse an existing checkout at the exact
pin. Exports come from Git objects, not uncommitted files. Image IDs, architecture,
task hashes, lockfiles and installed gem versions are recorded separately. Foundry
preparation also records the built gem and eight installed skills' source hashes.

Local overrides select Docker, offline oracle/no-op agents and no model. They replace
the upstream Daytona allowlist; they do not reproduce the published leaderboard.
`ft-i18n-support` installs `rails-i18n` 8.1.0 during setup. Its explicit local profile
permits dependency preparation and preinstalls that gem in a derived image. Fresh
verification checks the installed version instead of making an offline network call.
The upstream instruction and test files are unchanged. `prerequisites.json` records
this exception. Agent execution and fresh grading remain network-disabled.

The upstream SaaS Dockerfile starts from an AMD64-only image. Local preparation
preserves that original Dockerfile under `upstream-environments/` and builds the same
SaaS setup from the pinned Fizzy source image for the local architecture. Comparison
of the initial ARM build found all 1,769 tracked application files byte-identical;
only three empty `tmp` directory markers differed. Requirements, solution patches
and tests are unchanged. Report emulation and timeouts honestly; do not treat an unavailable or timed-out grader as
an expected no-op failure. An explicit local override allows 30 minutes for the SaaS
verifier rather than the upstream ten minutes; it changes no assertions or commands.
`local-overrides.json` records the base-image and time-budget overrides. The original
emulation attempts remain separate evidence. Upstream applications retain their own Ruby/Rails
versions; Ruby 3.4.10 is the contributor harness and Foundry fixture version.

## Offline controls and independent verification

Execution is the native Le Mans interface. `oracle` applies the reference solution;
`nop` does no coding. Neither invokes a model. The 45 Foundry control tasks include
24 valid implementations and 21 faulty implementations, including delegated and
relocated delivery. A faulty control must fail withheld behavior, not only package
checks. Zero native reward is expected for those negative controls.

The pinned CLI refreshes RubyLLM's model registry on the host before loading the
suite, including for oracle/no-op commands. That preparation may access registry
metadata; it is not model inference. Candidate execution and both grading phases
remain network-disabled. Do not describe the entire host process as air-gapped.

Protocol policy distinguishes restoration from prohibition. Upstream application-owned
`test/` and `saas/test/` changes are retained in the patch but restored before grading;
four pinned references legitimately edit them. Upstream runner and test-environment
controls remain forbidden. Foundry additionally protects its visible grading assets,
Gemfiles and task/agent instructions. Newly added application tests cannot award credit.
The exact task policy is recorded in each verification's `inputs.json`.

Upstream application tests run first with their existing skip semantics. A trusted
Minitest reporter records this baseline separately; a failing baseline stops the
task command, as it does upstream. Required task checks still reject skips. Both
phases share one timeout budget. Missing structured baseline evidence is an
infrastructure error, even when console output claims failure or success. Reporter
registration waits for the application's selected Minitest version, including
Minitest 6, without changing Le Mans internals.

```sh
bundle exec lemans run --bench /tmp/foundry-controls --agent oracle --concurrency 1 --runs-dir /tmp/foundry-native
benchmarks/suite replay /tmp/foundry-controls /tmp/foundry-native /tmp/foundry-verification
benchmarks/suite report /tmp/foundry-controls /tmp/foundry-report /tmp/foundry-verification/summary.json

bundle exec lemans run --bench /tmp/upstream-suite --agent oracle --concurrency 1 --runs-dir /tmp/upstream-oracle
bundle exec lemans run --bench /tmp/upstream-suite --agent nop --concurrency 1 --runs-dir /tmp/upstream-nop
benchmarks/suite replay /tmp/upstream-suite /tmp/upstream-oracle /tmp/oracle-verification
benchmarks/suite replay /tmp/upstream-suite /tmp/upstream-nop /tmp/nop-verification
benchmarks/suite report /tmp/upstream-suite /tmp/upstream-report /tmp/oracle-verification/summary.json /tmp/nop-verification/summary.json
```

Run replay only after native execution finishes. It checks task/profile identity,
reconstructs from the resolved starting image and declared setup, applies the binary
patch (including additions/deletions), records prohibited edits, restores protected
grading assets and executes trusted tests. No final candidate tree is trusted as a
grader. Native and independent outcomes remain separate; disagreement blocks
acceptance. Missing patches, failed reconstruction and unavailable graders are
infrastructure errors. Plain Rails receives no package penalty.

`verify WORKSPACE TASK PATCH OUTPUT` verifies a single captured patch. `report`
requires complete, unique task/agent coverage and reports attempted, valid, failed,
invalid-protocol and infrastructure-error counts. Smoke, atomic and feature results
are separate. A report over only successful tasks cannot pass the full-suite gate.

```sh
BENCHMARK_WORKSPACE=/tmp/foundry-suite BENCHMARK_EVIDENCE=/tmp/integrity-controls \
  bundle exec ruby benchmarks/acceptance/integrity_test.rb
```

These process controls exercise disabled assertions, skipped requirements, forged
summaries, protected edits, new/deleted files, missing/corrupt artifacts and synthetic
secret filtering. Pinned Le Mans' reporter probes assertion behavior. This is defense
against common protocol failures, not a claim of security against arbitrary hostile
Ruby capable of compromising its own process.

## Isolation and evidence

Candidate images contain only their starting application, dependency bundles and
the treatment's installed gem/skills. They do not include task solutions, hidden
tests, other trials, the Foundry checkout or repository history. Trusted evaluator
files are supplied only for grading.

Le Mans' native Docker environment requests `SYS_ADMIN`, `NET_ADMIN` and an
unconfined AppArmor profile. Use a disposable engine and review those upstream
requirements separately from the fresh grader. Independent verification drops all
capabilities, uses a read-only root and read-only evaluator mount, exposes no Docker
socket or host authentication, disables external networking and bounds CPU, memory,
processes and time. Application workdirs are disposable volumes. Fixture-only test
values baked into upstream applications are not live provider credentials.
Foundry graders allow 256 processes/threads; upstream graders allow 1,024 because
multi-device system tests start several Chromium sessions. A 256-limit diagnostic
allowed two sessions but rejected the third and incremented the cgroup `pids.events`
limit counter. This resource override adds no container capabilities.

Output directories are create-only. Native results are never rewritten or regraded
in place. Derived summaries retain source hashes and both outcomes. Corrections must
use new directories and an explicit selection/provenance manifest identifying the
original failure; never silently substitute a rerun. Redaction runs before contributor
artifact persistence. A patch changed by redaction is non-replayable and cannot pass.
Keep raw native artifacts under the pinned upstream secret filtering policy and
review them before sharing. Unknown usage or cost remains unknown.

## CI and future studies

`prepare-shard WORKSPACE OUTPUT SHARD` creates input subsets for `writebook-atomic`,
`fizzy-feature-0`, `fizzy-feature-1`, `fizzy-feature-2` and `saas`.
Fizzy features use a stable task-name hash to divide their larger application suite. It does no scheduling.
The acceptance workflow calls native Le Mans in each shard, independently verifies
both controls and uploads failure evidence. SaaS uses an AMD64 runner. Hosted
execution remains pending a repository destination.

Native `lemans report` remains the standard execution report. The contributor report
adds the independent-verification acceptance gate. Rails AI-evals measures upstream
Rails capability; Foundry's three-group tasks measure architectural treatment under
matched conditions. Neither offline control result measures coding-agent productivity.

The pinned Le Mans package includes native `miniswen` integration. A future study can
select that native agent after separately agreeing the model, credentials, tasks,
repetitions and budget. No live model or credential is configured here. Native support
does not provide Cursor subscription authentication or authorize provider spending.
Agent/model selection uses Le Mans' own `--agent miniswen` and `--model` options;
provider setup belongs to its pinned upstream documentation. The current offline
profile is not a live-agent configuration and must not be reused without the agreed
network, time, token and spend limits.

The completed Cursor pilot at `fde15a8a36c15fe648f31b5aa56f002d6883232b` remains
historical evidence. The pre-migration repository revision
`d6fa504d0140888c02010988e6127ed7fd3e2769` contains the old runner and its later
grader corrections. Use those Git revisions for historical reproduction; do not
mix their results with Le Mans controls. No additional agent trials are authorized.

The separately versioned [reviewed-AI feature study](reviewed-ai/README.md) uses these
same preparation and independent grading boundaries. Its fourteen offline controls are
verified; the proposed six coding-agent trials require separate authorization.
