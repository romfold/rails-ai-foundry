# 0007: Progressive package profiles

Status: accepted for local implementation; publication remains separate.

## Context

The approved architecture plan extends the gem-first workflow into complete consuming-app conventions. The supplied research organizes code by business context before layers and treats DDD, CQRS, and events as progressively adopted package capabilities. Earlier optional AI and example work must remain deferred.

## Decision

Retain packages/NAME and packages/platform/NAME, and introduce manifest version 2 with explicit mvp, modular, domain, or event_sourced profiles. One registry defines their combinations, component folders, and loading roots. Generated skill convention references use that registry. Keep ordinary filename-to-constant mapping, including category namespaces. Version 1 keeps its original paths and plain Ruby operations.

Use the user-selected Ruby 3.3 floor while retaining railties >=7.1. New application operations use dry-operation results and explicit constructors; dry-system provides explicit package composition without taking responsibility for autoloading. Rails owns lazy/eager loading and reloading. Host presentation, routes, jobs, initializers, and migrations remain normal Rails responsibilities. Owned models and records use an abstract Foundry Active Record base.

Keep modular/domain database state authoritative. Optional Rails Event Store 3.1 publication and local synchronous handlers share the primary database transaction; failure results and exceptions roll back publication. Authoritative aggregate streams use optimistic expected versions only in event_sourced. Projection processing records and a per-projection lock serialize idempotent updates and scoped rebuild. Rebuild invokes only the selected projection and never republishes stored events.

Preserve structural and Packwerk checks; add static declaration and layer checks over shared source roots. These checks cannot prove arbitrary dynamic Ruby, authorization, hidden IO, or read-only behavior through alternate connections. Runtime and pure Ruby acceptance provide separate evidence.

Promotion stages explicitly named components outside active load roots. Checked activation is explicit, preserves existing sources, and never executes data conversion. Event sourcing requires a reviewed migration, cutover, and rollback procedure. Six installed product skills and FOUNDRY.md guide consuming applications; upstream OpenSpec skills remain contributor tooling.

## Consequences

Developers get a predictable default and opt into complexity without a parallel folder taxonomy. Generated scaffolds require actual business implementation and tests. Long projection rebuilds hold local database transactions and need operational planning; distributed delivery remains a separate capability. Skill upgrades and profile transitions preserve edits and expose conflicts for review.

See the [research traceability table](../architecture/profiles.md), [event contract](../events.md), [promotion procedure](../promotion.md), and [compatibility evidence](../compatibility.md).

## Delivery supersession note — 2026-09-08

The delivery deferral for the support desk above is superseded by its verified completion and archive in commit `6acbc19` on 2026-09-08. The adopted core-first direction remains; broader examples require their own changes. The shipped catalog now has seven Foundry skills following guided adoption (commit `60d024e`, 2026-09-06), distinct from the six development OpenSpec workflows. Original decisions and milestone counts above remain historical records.

Optional AI profile alignment and execution tracking were subsequently verified and archived in commits `3f04ac6` and `53fdeac` on 2026-09-06. Those completed changes supersede the earlier expansion deferral for their specific scope.
