## Context

The September 22 trace reads `foundry-add-feature/references/packs.md`, then writes its illustrative profile despite reading root defaults and a conflicting explicit requirement. It subsequently inspects the JSON report without comparing the reported profile to that requirement. Generator defaults are already covered by core tests.

## Goals / Non-Goals

Make the decision clear at the point of copying package configuration and at verification. Retain eight skills and all profiles. Do not encode benchmark-specific expectations in the checker, modify submitted candidates, or inject Foundry into the unchanged upstream suite.

## Decisions

Keep one shared decision procedure in the packs reference, linked from the existing package/adoption skills. Explicit requested changes govern new work; preserve existing context intent otherwise; use root defaults for new contexts. Label the concrete example as illustrative and include a contrasting defaults example. Optional generator previews omit a profile override when using defaults.

Use existing installed-gem acceptance to exercise defaults, explicit overrides, custom roots and configuration discovery. Measure fresh untouched agent outputs separately. Only the two Foundry-group cells load the gem and skills; upstream failures cannot establish a Foundry defect without separate reproduction involving Foundry. All historical scores remain immutable.

## Risks / Trade-offs

Agent guidance is probabilistic → retain independent behavioral and architecture grading; do not promise a fresh ten-of-ten result. More instructions can distract → replace the ambiguous example framing and add a short decision rule rather than another skill or runtime. Paid measurements use the user-authorized $7 cycle-wide stopping budget; account for earlier cycle spend before any additional attempt.

## Fresh cohort and remaining treatment decision

The fresh study at revision `81889926643dc7a67757205da480769af3a9696b` records nine native passes and one failure; independent verification records nine passes and one infrastructure error. Both Foundry-treated cells pass. The remaining upstream candidate discarded its generated schema and could not reach baseline reporting. Its agent never received Foundry's existing schema/realtime guidance.

Preserve that cohort and its $0.13146371 provider-confirmed cost. The user selected the separately labeled Foundry-guided realtime treatment. Install the eight shipped skills from the measured gem in an isolated copy of the pinned Rails application, with workflow `none` and a generic agent entrypoint. Keep its application dependencies, feature requirements and upstream browser checks unchanged. This is explicitly a skills-only treatment; unavailable Foundry CLI checks are not claimed to run. Protect the installed treatment files during verification.

Do not inject instructions into the unchanged upstream suite, silently alter the comparison, or present a subsequent pass as a replacement score. No submitted-candidate repair is part of this work. Verify the new environment with offline controls and fresh grading before its single paid attempt, using the same model, provider and limits. Further evidence-driven fixes/retests share the existing $7 total stopping budget, with no automatic retries.

## First guided failure and reusable correction

The first guided attempt reads the feature/verification entrypoints but does not load their realtime reference. It includes schema changes and passes the unchanged application baseline, then both graders record four browser passes and two errors: hidden deletion controls and lost draft input. Source inspection finds nested owner selectors and child/parent replacement paths; these require browser interaction evidence rather than another model-only test.

Move the essential realtime acceptance boundary into the feature/verification entrypoints, before implementation: visible actor/viewer controls, idempotent effects, preserved input and explicit reporting of unexecuted browser checks. Keep detailed procedures in the shared reference, including nested ownership visibility and parent updates through touch/callbacks. Do not include fixture names, answers or evaluator source. Retest a newly built gem on a fresh starting application, preserving the failed guided attempt and charging its cost to the same cycle budget.

## Executable verification after the second guided failure

The user authorized fixing the verification workflow after a correctly delivered instruction was ignored. Package a Ruby helper under the existing foundry-verify skill. It runs ordinary Rails/Minitest commands in fresh processes with RAILS_ENV=test. The default baseline is the application test suite; explicit baseline paths support packs and custom roots. Require selected HTTP integration test files, and selected system test files when browser verification is requested. Preflight all paths before execution and retain command output. A Minitest reporter supplies actual per-test identities, assertions, type and outcome; stdout summaries or process exit zero alone cannot establish success. Missing evidence, empty selections, failures, errors, unreviewed baseline skips, selected-test skips and command timeouts fail the helper.

Use no production runtime, new Foundry CLI command, root configuration key, benchmark rule or agent runner. The helper is optional development tooling for Rails/Minitest HTTP features; RSpec and other callers keep their native verification. Keep detailed usage beside the existing skill. Application-owned CI must call the helper as a required step to enforce its result; installation alone cannot stop a coding agent from submitting. Reviewed tests and a trusted required CI job remain necessary: this helper does not prove assertion relevance, prevent deliberate application tampering or guarantee a model's score.

Test false-success controls with real Minitest subprocesses and installed-gem consumers under default/custom roots. Exercise real browser success and failure offline against a disposable Rails application with existing browser dependencies, without changing or repairing saved benchmark candidates. Preserve customized scripts and guidance under the existing receipt/collision rules. This intervention starts offline; any later paid treatment must freeze the changed inputs and retain the outstanding cycle accounting.
