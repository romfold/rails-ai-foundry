---
name: foundry-profile-promotion
description: Plan and implement an explicit context profile refactor without automatic conversion.
metadata:
  version: "1.0.0"
---

Read [application workflow selection](references/workflows.md) first and load only its selected upstream reference. Then read the owning context and [native conventions](references/native-conventions.md). For package creation, dependencies, public APIs or moves, read [packs usage](references/packs.md).

Run `bundle exec foundry plan refactor --context=NAME --profile=PROFILE` for a read-only report. Review source evidence and intended behavior. Propose configuration and namespace changes in the selected workflow. Implement authorized edits and test public contracts, Rails loading and rollback behavior. There is no automatic promotion or business-data conversion; selecting a profile does not select events, CQRS or capabilities.

For AI work, read [native AI guidance](references/ai.md). For architectural decisions, read [planning guidance](references/planning.md). Keep ordinary tests offline. Report behavioral test evidence separately from specification reconciliation.

Refactor evidence belongs only to the selected configured package, including its tests and lib.
Nested packages retain their own ownership even without foundry.yml; select configured children
separately. A proposed profile does not change which installed rules the assessment applies.

For existing-app extraction or persistence changes, read [adoption checkpoints](references/adoption-checkpoints.md). Verify characterization, caller boundaries and rollback at each relevant checkpoint; a completed assessment is not a completed migration.

When moving existing Rails delivery into a pack, read [delivery extraction](references/delivery-extraction.md). Preserve routes, model/data ownership and frontend behavior; verify native loading and assets independently from behavioral acceptance. This is conditional guidance, not an extra step for ordinary CRUD.
