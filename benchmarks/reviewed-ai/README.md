# Reviewed AI feature study: protocol v1

This is preparation, not an effectiveness result or authorization to run coding agents.
The existing six-task corpus, historical pilot and unfinished study acceptance stay unchanged.
Le Mans at the revision pinned in `benchmarks/Gemfile.lock` owns any future execution;
`benchmarks/suite` prepares inputs and independently grades captured patches.

## Question and treatment

Can the installed Foundry guidance and checks help an agent complete reviewed AI work
in an existing Rails/packs ticket application? Two groups receive the same SupportDesk
application, four unfinished service entrypoints, requirements, visible tests, offline
provider, PostgreSQL, Solid Queue, RubyLLM and browser dependencies. Workflow is `none`.
The upstream group receives Rails/packs/Packwerk guidance. The treatment also receives
the built Foundry gem, its eight installed skills, staged tutorial and checks.

The task adapts the public Assistance tutorial to SupportDesk under `components/`.
The tutorial is intentionally available to the treatment: this measures the combined
worked example, guidance and checking package. It cannot isolate a causal effect of
skills, establish independent-user usability, or support broad productivity claims.
Private acceptance cases are independently authored and absent from the candidate.
The reference restores the application services; a delegated equivalent must also pass.

## Prepare and validate offline

Use managed Ruby 3.4.10, the independently locked contributor bundle, Docker and the
canonical example's installed locked bundle/cache. Build-time dependency downloads
are allowed; candidates and graders have no provider credentials or external network.
The preparer copies only pure-Ruby gems selected by the canonical lock from the local
cache. Native Linux gems resolve at image construction. Missing dependencies stop the
build. Preserve resolved lockfiles and image IDs; never substitute versions silently.

```sh
bundle install --gemfile benchmarks/Gemfile
bundle install --gemfile examples/rails-native-agent-tools-structured-output-rubyllm/Gemfile
benchmarks/suite prepare-reviewed-study "$WORKSPACE"
benchmarks/suite images "$WORKSPACE"
benchmarks/suite dependencies "$WORKSPACE" "$DEPENDENCIES"
benchmarks/suite isolation "$WORKSPACE" "$ISOLATION"
benchmarks/suite reviewed-study-controls "$WORKSPACE" "$CONTROLS"
```

All output directories are fresh, external to the checkout, and separate from one
another. The manifest records input, prompt, skill, gem and evaluator hashes. Image
records and captured Linux lockfiles complete the freeze. Compare common dependency
versions before execution; a difference requires correction and fresh controls.
Preparation reads the current guide; a changed gem or guide requires a new workspace.
Controls reject changes to frozen files and preserve their individual failures.

The controls replay reference, delegated, approval-bypass, revision-bypass,
stale-generation, duplicate-effect and empty patches independently in both groups:
14 offline grades, **zero coding-agent trials**. Faults must fail actual assertions;
a crash is not a successful fault control. The real-service grader checks HTTP identity,
approval, tenant concealment, idempotency, cancellation, stale ownership, transaction
rollback on process death, post-commit replay, queue rediscovery and browser escaping /
input preservation. Packwerk and Foundry checks are separate from behavioral evidence.

Candidates never mount this repository, evaluator files, solutions, other attempts or
the Docker socket. The independent grader receives read-only evaluator files only
after the candidate patch is frozen, restores protected inputs, and uses disposable
PostgreSQL with no host database. Evaluation has a ten-minute total timeout, two CPU
cores, 2 GiB memory and a 256-process limit. Runtime infrastructure failures are recorded,
not graded as product success. Code remains untrusted: container isolation is a boundary,
not a claim of resistance to every adversarial evaluator-tampering technique.

## Proposed execution, requiring separate authorization

Propose three repetitions in each group, six serial trials, twenty minutes per trial
and at most two hours of agent execution. Fix agent, model, reasoning settings, exact
versions, access method and spend limits in a separate approval. No selection or
credential is supplied here. Stop on authentication/quota failure; no substitutions,
resets, retries or extra trials are implied. Native `nop` configuration is exclusively
an inert offline default; it is not the proposed coding agent.

Freeze a balanced order before execution: packs-1, foundry-1, foundry-2, packs-2,
packs-3, foundry-3. Use clean native Le Mans environments, identical hardware/resources,
requirements and network policy for every attempt. Any authenticated agent transport
must be confined to its approved endpoint without exposing evaluator mounts or unrelated
credentials. Rerun isolation checks for that approved transport before starting trials.
Do not execute directly against the reference/control workspace or expose its host
location to a candidate. Capture only the candidate patch, native events, duration,
usage and process outcome; grade in a new environment with the existing `verify` /
`replay` path. Review protocol violations separately even if behavior passes.

## Reporting contract

Keep one record per scheduled trial, including unstarted, timed-out and failed attempts:

| Field | Evidence |
| --- | --- |
| Identity | Group, repetition, source/gem/skill/task/evaluator hashes, image ID, agent/model versions |
| Behavior | Visible baseline, private HTTP, durability and browser assertions separately |
| Security/durability | Unauthorized effects, revision/lease acceptance, duplicate effects, lost-work failures |
| Verification compliance | Candidate's own test commands/results from native events; unknown when unavailable |
| Protocol | Changes to protected files, forbidden access, interventions and independent verification status |
| Infrastructure | Setup/auth/quota/transport/grader failures and timeouts, separate from assertion failures |
| Resources | Wall duration, reported tokens and monetary cost; unavailable values remain null/unknown |

Publish the six individual outcomes and denominators before any aggregate. Attribute
results to the exact freeze. Later fixes require another separately authorized study
before claiming improvement. Offline controls demonstrate grader sensitivity and
reproducibility only. No hosted CI, publication, spending or live provider evaluation
is authorized by this protocol.
