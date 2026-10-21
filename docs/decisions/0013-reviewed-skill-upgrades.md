# ADR 0013: Explicit reviewed skill upgrades

Status: accepted and locally verified, 2026-09-24.

## Context

Installed skills are application-owned customizations of shipped templates. Their receipts
record template hashes. Silent regeneration would lose local guidance, while wholly manual
catalog comparison makes verified improvements difficult to consume.

## Decision

Keep ordinary generation preserving. Offer an explicit generator upgrade with read-only
assessment, digest-bound application, pending decisions and conditional rollback. Compare
original template hashes, current files and incoming templates; do not invent original text
or automatically merge it. Publish the new template receipt only after explicit conflict
review; retain original snapshots and accepted customization provenance separately.

Use application-local, private filesystem journals and checked atomic file replacements.
This is development-time installation tooling, not an application workflow runtime.

## Consequences

Applications can receive untouched-file improvements while retaining reviewed exceptions.
Partial safe application is visible as pending, never complete. Recovery requires local
backups and cooperative POSIX filesystem access; no multi-file atomicity is claimed.
Instruction delivery remains separate from behavioral acceptance and agent effectiveness.
There are no new product skills, application configuration keys or production dependencies.
