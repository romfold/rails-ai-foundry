---
name: foundry-event-workflow
description: Design explicit event boundaries using upstream libraries and application-owned code.
metadata:
  version: "1.0.0"
---

Read [application workflow selection](references/workflows.md) first and load only its selected upstream reference. Then read the owning context and [native conventions](references/native-conventions.md). For package creation, dependencies, public APIs or moves, read [packs usage](references/packs.md).

Read the context event and CQRS selections independently. Selecting a pattern only records intent. Use direct upstream APIs and application-owned code; Foundry supplies no event bus, aggregate engine, projection processor or outbox runtime. Keep ordinary writes synchronous. Where durable publication is required, commit state and outbox intent in the same database transaction; publish afterward. Test duplicate delivery, crash windows, poison messages and optimistic conflicts. Foundry 0.4 includes independently verified PostgreSQL/Sidekiq outbox, RES ledger, OpenSearch, RabbitMQ and Kafka/NATS reference applications. Read the selected application-owned recipe, pinned bundle and acceptance evidence before adapting it. RES appends use expected stream versions. Queue acceptance is distinct from business completion; retain durable intent until the required acknowledgment. Kafka/NATS consumers commit effects or quarantine before acknowledging, and keep sequence gaps visible for repair.

For AI work, read [native AI guidance](references/ai.md). For architectural decisions, read [planning guidance](references/planning.md). Keep ordinary tests offline. Report behavioral test evidence separately from specification reconciliation.

For entrypoint contracts, realtime/Hotwire updates, resource bounds or durable delivery/rebuild changes, read [behavioral and recovery evidence](references/behavioral-recovery.md).

For AI proposals requiring a human decision before durable execution, read [reviewed AI work](references/reviewed-ai-work.md). Keep this conditional on the product requirement; ordinary CRUD and explicitly delegated tools retain their own contracts.
