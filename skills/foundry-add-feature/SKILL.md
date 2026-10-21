---
name: foundry-add-feature
description: Implement a feature in an existing Rails context using native upstream code.
metadata:
  version: "1.0.0"
---

Read [application workflow selection](references/workflows.md) first and load only its selected upstream reference. Then read the owning context and [native conventions](references/native-conventions.md). For package creation, dependencies, public APIs or moves, read [packs usage](references/packs.md).

For realtime/Hotwire work, read [behavioral and recovery evidence](references/behavioral-recovery.md) before choosing update targets. Define browser checks for the acting user and a separately subscribed viewer: working visible controls, one rendered effect, and preserved unsaved input through remote updates and refreshes. Trace parent updates from `touch` and callbacks too; an isolated stream target does not isolate its ancestors. Keep the composer outside destructive updates or demonstrate that its state survives them.

Inspect existing behavior, ownership, invariants, authorization and acceptance criteria. Implement ordinary application code; optionally scaffold with `bin/rails generate foundry:command NAME --context=CONTEXT` or the appropriate operation, query, model, delivery or agent generator. When using a scaffold, replace its exceptions with behavior and meaningful tests. For retrieval work, read [RAG adaptation](references/rag.md). Keep efficient reads close to Active Record and migrations at root. Verify failed operation results roll back writes.

Add and run tests through the changed feature's actual caller. A passing pre-existing suite establishes the baseline; model/controller tests alone do not establish interactive browser behavior. If a required browser check cannot run, report that behavior as unverified rather than complete.

For Rails/Minitest HTTP work, use the executable helper in the installed `foundry-verify` skill with selected integration tests and, for realtime behavior, system tests. Wire its invocation into the application's required CI checks. Define those tests before implementation, verify they reject the absent or faulty behavior, and run them again against the final code. A tool's nonzero exit blocks completion; do not substitute a smaller passing suite.

For AI work, read [native AI guidance](references/ai.md). For architectural decisions, read [planning guidance](references/planning.md). Keep ordinary tests offline. Report behavioral test evidence separately from specification reconciliation.

For other entrypoint contracts, resource bounds or durable delivery/rebuild changes, read [behavioral and recovery evidence](references/behavioral-recovery.md).

For AI proposals requiring a human decision before durable execution, read [reviewed AI work](references/reviewed-ai-work.md). Keep this conditional on the product requirement; ordinary CRUD and explicitly delegated tools retain their own contracts.

For everyday feature verification, opt in to the installed helper's `--include-pack-tests`
so root and upstream-discovered package tests share one non-system baseline. Keep caller
and browser selections explicit. Copy and adapt the installed gem's
`docs/package-aware-verification.md` into an application-owned `bin/verify-feature`;
preserve existing commands and require separate invocations for mixed frameworks.
Deliver helper updates through reviewed skill upgrades, then execute behavioral checks.
