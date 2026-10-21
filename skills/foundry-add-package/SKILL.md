---
name: foundry-add-package
description: Create a Rails context with independent Foundry architecture settings.
metadata:
  version: "1.0.0"
---

Read [application workflow selection](references/workflows.md) first and load only its selected upstream reference. Then read the owning context and [native conventions](references/native-conventions.md). For package creation, dependencies, public APIs or moves, read [packs usage](references/packs.md).

Establish ownership and invariants with [planning guidance](references/planning.md). Resolve the requested profile and independent patterns before creating the package, following [architecture selection](references/packs.md); example values are not application defaults. Use the locked upstream packs CLI to create the package and add explicit foundry.yml intent. The Foundry context generator is an optional scaffold; preview it when selected. Keep existing consumer roots. Declare cross-pack dependencies and public paths in package.yml. Run structural checks and loading tests.

For AI work, read [native AI guidance](references/ai.md). For architectural decisions, read [planning guidance](references/planning.md). Keep ordinary tests offline. Report behavioral test evidence separately from specification reconciliation.

After creating or extracting a Foundry context, inspect `bundle exec foundry check --sources --format=json` and confirm its exact package path, namespace and profile in `contexts`. A successful check with zero contexts is not completed extraction. See [sidecar placement](references/packs.md); ordinary upstream packages without Foundry intent remain valid.

When moving existing Rails delivery into a pack, read [delivery extraction](references/delivery-extraction.md). Preserve routes, model/data ownership and frontend behavior; verify native loading and assets independently from behavioral acceptance. This is conditional guidance, not an extra step for ordinary CRUD.
