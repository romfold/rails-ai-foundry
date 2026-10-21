---
name: foundry-verify
description: Verify Foundry configuration, upstream boundaries and application behavior.
metadata:
  version: "1.0.0"
---

Read [application workflow selection](references/workflows.md) first and load only its selected upstream reference. Then read the owning context and [native conventions](references/native-conventions.md). For package creation, dependencies, public APIs or moves, read [packs usage](references/packs.md).

For Rails HTTP features using Minitest or RSpec, run the bundled [verification helper](scripts/verify.rb) from the application root with explicit `--caller` integration test files. Include `--realtime --browser` system test files for realtime work. Select `--framework=rspec` for RSpec; Minitest remains the default. It executes the baseline and selected tests and rejects missing, empty, pending/skipped or failing evidence; RSpec expectation counts remain unavailable. Read [usage and CI integration](references/verification.md), then make this invocation a required application CI step. Installation alone cannot enforce completion; a caller must check its exit status. Review the chosen tests against the requirements before accepting a pass.

For realtime/Hotwire changes, read [behavioral and recovery evidence](references/behavioral-recovery.md) and run browser checks for both actor and subscribed viewer. Exercise visible controls through their reveal/submit/cancel states; inspect effective visibility when nested records have different owners. Confirm unsaved input survives remote updates, including ancestor replacements or refreshes, and that response/broadcast echoes produce one effect. A green model/controller or pre-existing suite is insufficient evidence for these interactions; report unexecuted checks explicitly.

Run `bundle exec foundry check --sources` without booting Rails. It checks shell app/ and all upstream package app/ Ruby sources, including packages without foundry.yml; profile rules still require the owning context's intent. Inspect files_checked and remember that static parsing does not establish behavioral coverage. Run `bundle exec foundry check --boundaries` in the isolated test environment to delegate to Packwerk. Preserve accepted debt; never regenerate a baseline to hide new violations. Run the application behavioral tests and relevant workflow-specific checks. Report each result and unresolved limitation; specification validation is not evidence of working behavior.

Before claiming a package boundary is enforced, inspect its dependency/privacy settings and verify an intentional private-access violation in a disposable copy, as described in [packs usage](references/packs.md). If the task marks existing tests or other files as immutable, add regression coverage in new permitted test files and inspect the final diff for protected-file edits, including additions that leave existing assertions intact.

For AI work, also run `bundle exec foundry check --prompts` and the owning offline evaluations; static contract success is not behavioral evidence. Read [native AI guidance](references/ai.md). For architectural decisions, read [planning guidance](references/planning.md). Keep ordinary tests offline. Report behavioral test evidence separately from specification reconciliation.

For accepted-debt cleanup, run `foundry audit` and review resolved identities before editing a baseline. Keep Packwerk authoritative; pks requires explicit application-specific parity and fresh evidence after input/tool changes. For performance claims require matched conditions, repeated samples and held-out behavior; separate runtime and onboarding measurements.

For audit input exclusions and parity regeneration, read [adoption checkpoints](references/adoption-checkpoints.md).
The verified capture excludes private backups but does not sandbox application boot.

For existing-app extraction or persistence changes, read [adoption checkpoints](references/adoption-checkpoints.md). Verify characterization, caller boundaries and rollback at each relevant checkpoint; a completed assessment is not a completed migration.

For other entrypoint contracts, resource bounds or durable delivery/rebuild changes, read [behavioral and recovery evidence](references/behavioral-recovery.md).

After creating or extracting a Foundry context, inspect `bundle exec foundry check --sources --format=json` and confirm its exact package path, namespace and profile in `contexts`. A successful check with zero contexts is not completed extraction. See [sidecar placement](references/packs.md); ordinary upstream packages without Foundry intent remain valid.

Compare the assessed profile and independent patterns with the requested architecture. A valid configuration can still implement the wrong request; a structural pass does not establish intent compliance.

For persistence changes, verify both migration from the starting database and preparation of a fresh database from the committed schema. Inspect the application's schema format, database roles and identifier types before adding references. Include its generated schema changes in the delivered patch; a migrated local database alone cannot prove that a clean checkout works.

For AI proposals requiring a human decision before durable execution, read [reviewed AI work](references/reviewed-ai-work.md). Keep this conditional on the product requirement; ordinary CRUD and explicitly delegated tools retain their own contracts.

For everyday feature verification, opt in to the installed helper's `--include-pack-tests`
so root and upstream-discovered package tests share one non-system baseline. Keep caller
and browser selections explicit. Copy and adapt the installed gem's
`docs/package-aware-verification.md` into an application-owned `bin/verify-feature`;
preserve existing commands and require separate invocations for mixed frameworks.
Deliver helper updates through reviewed skill upgrades, then execute behavioral checks.

When moving existing Rails delivery into a pack, read [delivery extraction](references/delivery-extraction.md). Preserve routes, model/data ownership and frontend behavior; verify native loading and assets independently from behavioral acceptance. This is conditional guidance, not an extra step for ordinary CRUD.
