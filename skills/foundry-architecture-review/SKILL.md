---
name: foundry-architecture-review
description: Review Rails context boundaries, independent patterns, and runtime coupling.
metadata:
  version: "1.0.0"
---

Read [application workflow selection](references/workflows.md) first and load only its selected upstream reference. Then read the owning context and [native conventions](references/native-conventions.md). For package creation, dependencies, public APIs or moves, read [packs usage](references/packs.md).

Read package.yml, pack-local foundry.yml and root defaults. Run `bundle exec foundry check --sources`; inspect its certainty and limitations. Use `--boundaries` only in an isolated test application with a locked bundle. Report concrete dependency/privacy violations and behavior risks with file locations. Prefer constructor injection and direct upstream APIs.

For AI work, read [native AI guidance](references/ai.md). For architectural decisions, read [planning guidance](references/planning.md). Keep ordinary tests offline. Report behavioral test evidence separately from specification reconciliation.

For debt cleanup or parity, read [adoption checkpoints](references/adoption-checkpoints.md).
Verify captured inputs and regenerate stale evidence; private backups are not analysis inputs.
