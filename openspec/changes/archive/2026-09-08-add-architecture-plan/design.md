## Context

See proposal.md. Existing PackageInstaller commits one package and uses tracked ScaffoldInstaller writes; batching it cannot provide all-or-nothing installation. Manifest/Graph/FileSystem already define structural and path rules.

## Goals / Non-Goals

**Goals:** Optional file-based recommendations, exact-input review, shared preflight and resumable additive installation.

**Non-Goals:** Authenticated approvals, mandatory planning, migrations, batch rollback, Rails initialization, Packwerk execution or new profiles.

## Decisions

- Internal Plan namespace uses explicit requires, with Document, Advisor, Files, Preflight, Application and Command responsibilities. Existing root API stays unchanged.
- Questionnaire and plan entries use an `answers` mapping with exactly four named booleans; all other entry fields are siblings. No approval status. Reuse SafeYaml and synthetic v2 Manifest parsing for declaration validation. Unknown fields fail closed.
- Advisor's ordered table is the source for the installed planning reference. Overrides are advisory; event source acknowledgement is structural policy. Ownership confirmation is required for adopt apply (including pretend), not for draft validation.
- Digest uses SHA256 of JSON array ["rails-ai-foundry-plan-v1", canonical root, exact plan bytes]. It does not include mutable manifest state so exact-match resume works. Revalidate that state independently.
- Extract shared package destination preflight from PackagePlan for reuse against the combined virtual manifest; do not call installers in pretend to validate absent interdependent packages.
- Kahn ordering picks the alphabetically first available package at every step. Dependencies already installed outside the plan do not become actions.
- Safe root-contained paths reject dot/dotdot/empty components and symlink ancestors. Proposal refuses any existing destination and uses the tracked ScaffoldInstaller lifecycle, including on exclusive-create races.
- Apply validates whole plan before writing, then reloads and preflights before each package, comparing source bytes before invoking existing PackageInstaller. Earlier completed packages are never rolled back. Print progress even on failure; per-package publication remains the final mutation of that installer.
- CLI root defaults to cwd, file/out default to foundry/plan.yml; answers and reviewed digest are required for their respective actions. Diagnostics use [plan.command] plus existing actionable details. Successful output names downstream check/test commands.

## Risks / Trade-offs

Editable confirmations and digests do not prove a human reviewed anything; skill guidance obtains approval and documents the limit. Concurrent mutations are detected at existing filesystem checkpoints, not prevented by a global lock. Partial success is explicit and resumable. Plans record additions, not an alternative installed registry.

## Migration Plan

No manifest migration or automatic catalog upgrade. Existing commands continue to work. Eight-skill catalog changes require manual review of older receipts. ADR 0010 records these decisions.
