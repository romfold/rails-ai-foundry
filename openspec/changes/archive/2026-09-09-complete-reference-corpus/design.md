## Context

Four independently verified apps exist, with a lean Rails shell, pack-owned behavior and standalone verification scripts. Core conventions and workflow tooling are stable at 0.3.0.

## Goals / Non-Goals

Deliver all eight remaining apps and real upstream integrations. Keep each app independently runnable; do not add a shared execution framework or require optional libraries in the core gem. Production-scale benchmarks, ROM and experimental vector adapters remain outside 0.4.

## Decisions

- Reuse the proven shell structure as development-time scaffolding, not a runtime shared between examples. Each app owns migrations, configuration, bundles, workflow artifacts and tests.
- Use PostgreSQL for persistence and disposable local services for Qdrant, Kafka, NATS and Redis. Provider transports are stubbed offline; data and broker integrations are exercised for real.
- Chat uses direct RubyLLM, persistent messages and Turbo Stream responses. Agent tools use direct RubyLLM::Tool/Schema with trusted constructor scope and application validation.
- Qdrant remains a rebuildable derived index with authoritative PostgreSQL records, tenant/version payload filters and alias cutover. A small HTTP client at the real external boundary uses Qdrant's upstream REST API.
- Kafka/Karafka owns a versioned event pipeline and idempotent database effects. A NATS JetStream recipe lives in that same app with independent durable-consumer verification, avoiding a thirteenth catalog application.
- Sidekiq runs application-owned outbox work against Redis/PostgreSQL. RES ledger app appends authoritative events with expected versions and rebuilds state through direct Rails Event Store APIs.
- GraphQL uses upstream AsyncDataloader; capture trusted tenant/database role explicitly for suspended work and verify cleanup. Falcon is the optional server in that app. Next.js is a separate frontend directory inside a Rails-root app with its own locked Node dependencies.
- Initialize each greenfield app with pinned Spec Kit 1.0.0 and retain small living requirements/plan/tasks/reconciliation artifacts. Foundry's repo stays on OpenSpec.

## Risks / Trade-offs

Small deterministic fixtures demonstrate correctness, not production quality or capacity. Dependency conflicts are resolved and recorded in each locked integration lane. Infrastructure failures leave tasks unchecked until real service recovery passes. Do not claim remote CI or live provider evaluation from local checks.

## Migration Plan

Add independent apps without altering existing consumer behavior. Verify each app before adding it to the catalog, then run core compatibility and all-corpus checks. Archive only after all tasks pass; publishing remains separate.
