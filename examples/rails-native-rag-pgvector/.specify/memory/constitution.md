# Tenant-scoped retrieval and evidence answers: constitution

Version: 1.0.0. Ratified: 2026-09-09.

Use ordinary Rails and upstream dependencies. Foundry is development tooling only.
Architectural constraints live in [the application configuration](../../config/foundry.yml),
[the focal context](../../packs/knowledge/foundry.yml), and adjacent package.yml files.
Do not copy their inventories here.

Enforce authorization in application code, preserve authoritative state on integration failure,
and test replay and recovery. Never infer correctness from an agent completion report.
Normal tests allow loopback integration services only and never contact model providers.

Maintain a living behavioral specification. When requirements change, reconcile spec.md,
plan.md and tasks.md with implementation and evidence. This persistence convention is a
Foundry recommendation, not a requirement imposed by Spec Kit.
