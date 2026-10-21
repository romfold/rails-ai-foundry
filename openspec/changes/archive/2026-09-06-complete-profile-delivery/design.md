## Context

The first five bounded changes implement profile runtimes and static checks. Safe scaffold installation already preserves user edits with receipts; package registration uses guarded manifest replacement. See proposal.md for the remaining delivery gap.

## Goals / Non-Goals

Goals: explicit, reversible promotion preparation and archive-delivered workflow coverage.
Non-goals: infer business names, rewrite operations into commands, relocate existing models automatically, execute cutover commands, or publish a release.

## Decisions

Stage explicitly requested `--components kind:name` scaffolds under package `.foundry/promotions/PROFILE/files`, outside active app roots. A candidate copy overlays those artifacts and the target manifest for static checks. The preview explains newly supported responsibilities and reports target violations; users choose business component names and manually resolve behavioral changes. A matching receipt preserves edited staged files. Activation rejects destination collisions and rechecks source snapshots before publishing the manifest; new writes use the existing exclusive-write rollback engine.

Version 1 remains read-only to promotion. Event-sourcing activation additionally requires a completed CUTOVER.yml with approved status and concrete migration, cutover, and rollback procedures. This records explicit review without pretending to execute or verify production data migration.

Install six skills with shared bundled workflow/event references and a convention reference rendered from the canonical registry. Keep skill metadata aligned with the unpublished gem version; changed catalog digests require manual upgrade review. Generate FOUNDRY.md separately from existing AGENTS.md so application instructions remain untouched.

Extend archive tests to execute profile workflows from isolated installed gem paths. Block network sockets, reuse only fixture/behavior test data from the repository, and verify all framework implementation resolves from the archive.

## Risks / Trade-offs

Target static checks cannot prove business behavior or data readiness: promotion guidance requires package/runtime tests and manual migration review. Staging consumes a temporary candidate copy for deterministic analysis. Long-running concurrent edits are detected before registration; no existing source is automatically overwritten.

## Migration Plan

Keep the current profile until explicit activation. Review additive staged files and resolve existing incompatible locations manually. Upgrading skills with a changed receipt requires a reviewed diff rather than automatic replacement. Publishing remains a separate decision.
