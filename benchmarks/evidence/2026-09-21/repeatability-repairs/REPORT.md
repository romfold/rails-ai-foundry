# Repeatability repairs and protocol hardening — 2026-09-21

All ten offline positive controls passed in fresh credential-free, network-disabled
containers. Both original negative controls retained their expected rejection.
These are **human-assisted regression and reference controls, not a 10/10 agent score**.
No paid calls, new coding-agent attempts, model substitutions or automatic retries ran.
The stopped paid study remains five passes, one failure, one invalid and three unstarted.

## What changed

- Repaired the saved boundary candidate by adding `enforce_privacy: true` to the
  Knowledge package. Its existing API, schema, sidecar and behavior are preserved.
- Repaired the saved embedding candidate by restoring the protected visible test
  file and moving its two added tests into a separate permitted test file/class.
  Its application implementation is unchanged. The relocated tests passed 2 tests /
  6 assertions before trusted grading.
- Existing packs and verification skills now explain that a public path alone does
  not enable privacy and recommend an intentional private-access probe in a disposable
  copy. They distinguish application tests from files explicitly protected by a task.
- All three Foundry groups receive the same explicit protected-file list and new-test
  placement example. Task requirements and upstream instructions remain unchanged.
- Future studies can continue after a fully diagnosed non-smoke protocol violation,
  while preserving its invalid score and accounting. Native completion, independent
  task verification, an explicit underlying grade matching native reward, recorded
  protected paths, immutable evidence and known accounting are required. Failed smoke,
  missing verification, authentication failure, infrastructure errors and grader
  disagreement still stop. Old frozen workspaces cannot use changed contributor code.

The verifier retains its underlying status before applying the protocol rejection,
so an infrastructure error cannot masquerade as a safely completed invalid attempt.
Neither protected-file policy nor architecture acceptance was weakened.

## Offline task results

| Task | Input | Result |
| --- | --- | --- |
| hello-world | Unchanged saved candidate | pass |
| boundary-extraction-rails | Unchanged saved candidate | pass |
| boundary-extraction-packs | Unchanged saved candidate | pass |
| boundary-extraction-foundry | Separate repaired candidate | pass |
| stale-embedding-rails | Unchanged saved candidate | pass |
| stale-embedding-packs | Unchanged saved candidate | pass |
| stale-embedding-foundry | Separate repaired candidate | pass |
| ar-tenant-isolation | Pinned upstream reference | pass |
| aj-enqueue-after-commit | Pinned upstream reference | pass |
| ft-comment-reaction-live-echo | Pinned upstream reference | pass |

The three upstream references validate executable requirements, not model capability.
The live-reaction reference passed all six unchanged browser tests / 35 assertions;
its application baseline passed 1,517 / 5,708 with two pinned Vips capability skips.
The smaller upstream application baselines passed 179 / 553 with the same two skips.
Selenium's blocked external metadata requests are retained in offline logs.

The original boundary candidate still fails for missing privacy enforcement. The
original embedding candidate still receives `invalid_protocol` for modifying
`test/visible_test.rb`, even though restored behavior and architecture tests pass.
No original patch, grade or cost was overwritten.

## Reproduction and provenance

Original frozen workspace: `/private/tmp/foundry-openrouter-luna-20260921-r3-v2`.
Original task revision: `b40528965c0360bd15f2702652f731fa29d1baec`.
Original study manifest SHA-256:
`2b32a3052b6127ea028c882c40cf92e68a312e559c154dd3f3448b13b17307ea`.
Le Mans remains 1.3.5 at `2d0b7fb8d3b0077574dcf7b70fd4e32c8f9d6e76`;
AI-evals remains `5327efe54dd767d662ab89332f6a4285fef07bd8`.

[Repair fixtures](../../../repairs/sets/repeatability-2026-09-21/README.md) document
independent verification commands. `provenance.json` there records original and
repair hashes, image/task identities and reconstructed trees. Applying original plus
incremental repair produced the same tree as applying the complete patch for both:

- Boundary: `804af268196e47e54ebfe5f90c91ef229d405693`.
- Embedding: `f4d6b9cb43ac86217b9a7eb4951dc4ba654ba49d`.

Offline matrix output originated at `/private/tmp/foundry-repeatability-repairs-20260921`.
Each directory contains a captured patch, source/input hashes, protocol policy,
verification logs and result. `summary.json` labels saved, repaired and reference
inputs separately. `artifact-inventory.json` verifies byte-identical copies;
`history.json` verifies all tracked historical evidence and repair files unchanged.
New fixtures are contributor-only and are never installed into candidate skills.

To replay a positive row, run the existing contributor verifier with its original
suite/task and the archived row's `agent.patch`, choosing a new output directory:

```sh
export BUNDLE_GEMFILE="$PWD/benchmarks/Gemfile"
bundle exec ruby benchmarks/suite verify "$STUDY/foundry" boundary-extraction-foundry \
  benchmarks/evidence/2026-09-21/repeatability-repairs/03-boundary-extraction-foundry/agent.patch \
  "$NEW_EVIDENCE/boundary"
```

Use `$STUDY/smoke` for hello-world and `$STUDY/upstream` for the upstream rows.
Never treat these commands as native model trials or resume an old frozen study.

## Verification and development failures

- Contributor: 64 tests / 542 assertions passed, including continuation, invalid smoke,
  missing task grading, hidden infrastructure errors, native authentication failures,
  grader disagreement, immutable inputs and cost guards.
- Core: 147 tests / 1,134 assertions passed.
- Installed gem: 6 tests / 416 assertions passed; ordinary loading, default/custom
  roots, intentional private violations, accepted debt and generated guidance covered.
  Deliberately broken delivery assertions in the output are expected negative controls.
- RuboCop: 705 files, no offenses after corrections.
- Skills: six development and eight product skills validated by the repository script.
- Catalog: twelve executable examples validated.
- Contracts: eight schemas / 73 cases; 10 tests / 142 assertions passed.
- Strict OpenSpec: 31 items passed after syncing requirements and archiving the change.

An early contributor test incorrectly reused a create-only test output; its fixture
cleanup was fixed and the suite rerun. RuboCop initially reported complexity and
formatting issues; the helpers were simplified without suppressions. Docker could
not copy the repair patch from tmpfs; the offline preparer read it through Docker
exec instead, then verified both reconstruction paths. Initial file inspections used
several nonexistent names before the actual paths were located. The optional
skill-creator Python validator could not import PyYAML in either available Python;
the repository's skill validator and installed-gem acceptance passed. No dependencies
were added merely to run that optional validator.

A fresh ten-trial paid study was offered with the same model and a $7 stopping budget;
no answer was received during this implementation, so none was launched. A future
measured run must use new frozen inputs and report whatever outcomes occur. These
fixes cannot guarantee a particular model's score or justify retrying until it passes.
