# Architecture planning from behavior

Use this reference when ownership, invariants or integration boundaries are uncertain. Read the selected workflow and owning source/configuration first. Resolve discoverable facts in code before interviewing the user. Ask only questions that materially affect behavior or architecture; continue independent work while answers are pending.

Establish these decisions in the selected workflow's plan (or a plain project plan with none):

| Decision | Evidence to collect |
| --- | --- |
| Ownership | Which context owns each business decision and state change? Who consumes its public API? |
| Invariants | What must remain true, including validation, authorization, tenant isolation and failure behavior? |
| State and consistency | Which database is authoritative? What commits atomically? Can a caller observe pending work? |
| Integrations | Which real external boundaries need ports, retries, idempotency or recovery? |
| Workload | Measured query counts, latency, allocations, pool pressure, queue lag and expected data size |
| Acceptance | Observable successful and failed behavior, regression coverage and evidence needed before completion |

Choose rails_native for ordinary Rails behavior, modular when ownership requires boundaries, and domain for complex business rules that benefit from a pure domain. Efficient persistence queries are valid in every profile. Repositories and ports serve real boundaries; ordinary Active Record access needs no mandatory wrapper.

Profile, events, CQRS, capabilities, workload and workflow are independent. Propose changes to installed configuration explicitly and reference its paths; never duplicate the package graph or assign an architecture score. Keep ordinary writes synchronous. Use durable background work where persisted intent, status and failure handling improve the use case. Sharding, read replicas, caching and async servers require evidence and a concrete consistency/operations plan.

Create bounded tasks tied to behavioral acceptance. State the owning files, proposed public API/dependencies, transaction and provider boundaries, rollout/recovery needs and unresolved evidence. Implement with native Rails/upstream APIs and constructor injection. Small generators can save typing but do not choose architecture or prove completion. For package changes, read [packs usage](packs.md). Reconcile requirements and tasks after behavior is verified; specification validation and agent completion reports are separate evidence.

For everyday feature verification, opt in to the installed helper's `--include-pack-tests`
so root and upstream-discovered package tests share one non-system baseline. Keep caller
and browser selections explicit. Copy and adapt the installed gem's
`docs/package-aware-verification.md` into an application-owned `bin/verify-feature`;
preserve existing commands and require separate invocations for mixed frameworks.
Deliver helper updates through reviewed skill upgrades, then execute behavioral checks.

For an existing configured context, run `bundle exec foundry plan refactor --context=NAME`
before proposing a profile change. The report inspects that package's non-hidden Ruby,
including tests and lib, using installed intent. Independently discovered nested packages are excluded
even without foundry.yml; assess configured children separately. Unconfigured packages
remain covered by `foundry check --sources`, not implicit profile selection.
A configured upstream root package is selectable; its scan excludes vendor, node_modules,
tmp, log, storage and coverage at application root. Completion is static assessment,
not proof of migration, constant resolution or behavior. Preserve tests, Packwerk evidence
and accepted debt as separate requirements. Receive updated guidance through reviewed skill upgrades.
