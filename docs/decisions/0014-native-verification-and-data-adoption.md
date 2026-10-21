# 0014: Native verification evidence and application-specific data adoption

Status: accepted, 2026-09-24. Executable reconciliation is recorded in the RSpec and
populated-adoption evidence; release verification remains a separate gate.

## Context

Rails consumers use both Minitest and RSpec. Foundry's installed verification helper
must recognize executed request/system behavior without presenting one framework's
assertion metrics as another's. Existing adoption demonstrates package extraction, but
an empty database or a persistence swap does not demonstrate safe ownership backfill.

## Decision

Keep explicit framework adapters in the development-time skill helper. Minitest remains
the default. RSpec uses its native formatter notifications, selected-file/type attribution,
completion and outcome checks. Reject narrowed, pending selected and incomplete runs.
Expectation counts are unavailable: an expectation-free passing example can pass this
adapter. Test review and deliberately faulty controls remain necessary. Neither adapter
is a sandbox against a malicious application that rewrites its own evidence.

Demonstrate populated-data migration inside the existing adoption recipe. Extract a useful
Knowledge pack first. Keep trusted collection ownership authoritative until compatible
writers, bounded transactional backfill, reviewed unresolved ownership and staged database
constraints establish the new invariant. Use a short application writer gate only to
switch reads; retain additive data and compatible writers on rollback. PostgreSQL,
Active Record, packs/packs-rails and Packwerk are sufficient for this scenario.

## Consequences

RSpec remains an optional independent acceptance dependency. Supporting tested combinations
does not imply all RSpec/Rails combinations work. Installed upgrades deliver helper changes
through the existing ownership and review rules, without upgrading application behavior.

Backfill coordination, ownership rules and operator tasks belong to this application;
Foundry supplies guidance and checks, not a migration runtime. Old-writer shutdown requires
operator confirmation; the fixture cannot prove that an external deployment has stopped.
Ownership transfers are excluded. DDL validation runs outside the writer gate; lock and
statement timeouts bound individual operations, with possible in-flight timeout overshoot.
