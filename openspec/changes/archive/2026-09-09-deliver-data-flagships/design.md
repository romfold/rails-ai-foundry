## Context

The 0.2 core provides native generators, safe setup and explicit Packwerk checking. No standalone examples remain. Existing installed-gem tests already establish accepted/new/stale debt behavior, making adoption the first independent flagship.

## Goals / Non-Goals

Deliver executable application-owned recipes and behavior evidence. Do not introduce Foundry event, index, transaction, AI or specification runtimes. Do not claim later examples complete from configuration or mocked integrations alone.

## Decisions

- Build the adoption application first using a small invoice domain. Preserve one existing root-service access to a private Billing model as reviewed Packwerk debt. Add a public Billing API and verify legacy/public report parity. Run new-debt and extraction scenarios in disposable copies; never mutate accepted source debt during verification.
- Give every application its own Gemfile/lock and workflow artifacts. Use an explicit development path to the monorepo gem; production uses upstream gems directly. The adoption app uses SQLite because extraction does not require database-specific semantics. PostgreSQL is mandatory for outbox and pgvector correctness lanes.
- Catalog only delivered apps, with location and focal context. Read profile from the context rather than repeating capabilities or topology. Preserve custom consumer roots.
- Add outbox and indexing code to consuming applications/recipes, not the gem execution path. Use direct upstream clients. Pin tested service/client combinations when their integration is implemented.
- Normal application tests prohibit model-provider traffic. Data/broker integration lanes use disposable local services. Index recovery and message crash windows need real integration evidence; provider stubs alone cannot complete those tasks.
- Three greenfield flagships use pinned Spec Kit setup. The adoption app uses pinned OpenSpec. Each workflow references application configuration instead of maintaining another package inventory.

## Risks / Trade-offs

- Packwerk can miss fully resolved stale baselines: explicitly review and remove the resolved identity in the disposable extraction scenario, then check the resulting dependency graph.
- Example bundles can accidentally inherit monorepo tooling: own lockfiles, application-local workflow detection and independent CI prevent false acceptance.
- Service availability can delay integration verification: keep affected tasks pending and avoid substituting configuration checks for runtime evidence.

## Migration Plan

Introduce examples independently without changing existing consumers. Keep 0.3 in progress until all four flagships and their recipes pass. Preserve historical records and commit verified slices. Publishing remains separate.
