---
name: foundry-adopt-existing-app
description: Assess and incrementally adopt an existing Rails app without rewriting its topology or debt.
metadata:
  version: "1.0.0"
---

Read [application workflow selection](references/workflows.md) first and load only its selected upstream reference. Then read the owning context and [native conventions](references/native-conventions.md). For package creation, dependencies, public APIs or moves, read [packs usage](references/packs.md).

Start with `bundle exec foundry adopt --format=json`, which is read-only. Preserve existing roots and established specification workflow; an unconfigured brownfield application is recommended OpenSpec. Review proposed setup before applying it. Introduce contexts incrementally, preserve upstream baselines, and run Packwerk plus behavioral regression tests. Do not claim pks parity or complete migration from source diagnostics.

For AI work, read [native AI guidance](references/ai.md). For architectural decisions, read [planning guidance](references/planning.md). Keep ordinary tests offline. Report behavioral test evidence separately from specification reconciliation.

Use `foundry audit` for complete new/retained/resolved debt identities; regeneration occurs only in a disposable copy. `foundry parity --pks=PATH` compares the application with Packwerk, and `--verify=REPORT` rejects stale evidence. Store reports outside the application, preserve original baselines, and use a disposable test database because Packwerk may boot Rails.

For existing-app extraction or persistence changes, read [adoption checkpoints](references/adoption-checkpoints.md). Verify characterization, caller boundaries and rollback at each relevant checkpoint; a completed assessment is not a completed migration.

Before extraction, resolve the intended context profile and independent patterns using [architecture selection](references/packs.md). After creating or extracting a Foundry context, inspect `bundle exec foundry check --sources --format=json` and compare its exact package path, namespace, profile and patterns in `contexts` with that selection. A successful check with zero contexts or a different valid profile is not completed extraction. Ordinary upstream packages without Foundry intent remain valid.

When moving existing Rails delivery into a pack, read [delivery extraction](references/delivery-extraction.md). Preserve routes, model/data ownership and frontend behavior; verify native loading and assets independently from behavioral acceptance. This is conditional guidance, not an extra step for ordinary CRUD.
