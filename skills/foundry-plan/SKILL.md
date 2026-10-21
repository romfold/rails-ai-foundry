---
name: foundry-plan
description: Plan a Rails application change using installed architecture constraints and its selected specification workflow.
metadata:
  version: "1.0.0"
---

Read [application workflow selection](references/workflows.md) first and load only its selected upstream reference. Then read the owning context and [native conventions](references/native-conventions.md). For package creation, dependencies, public APIs or moves, read [packs usage](references/packs.md).

Inspect existing behavior and the requested change. Establish ownership, invariants, state/consistency, integration boundaries and measured workload using the planning reference. With workflow none, keep a plain plan and acceptance criteria in the application; no external workflow is required. Keep requirements in the selected specification workflow and implementation rationale in plans or ADRs. Reference authoritative foundry.yml and package.yml files instead of copying inventory. Use `foundry plan refactor` for source evidence when changing an existing context. Define bounded implementation tasks with behavioral acceptance criteria; generators are scaffolds, not completed behavior.

For AI work, read [native AI guidance](references/ai.md). For architectural decisions, read [planning guidance](references/planning.md). Keep ordinary tests offline. Report behavioral test evidence separately from specification reconciliation.

For existing-app extraction or persistence changes, read [adoption checkpoints](references/adoption-checkpoints.md). Verify characterization, caller boundaries and rollback at each relevant checkpoint; a completed assessment is not a completed migration.
