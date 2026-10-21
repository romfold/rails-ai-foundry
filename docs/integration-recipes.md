# Application-owned integration recipes

The [twelve-app catalog](../examples/catalog.yml "Repository-only reference; not installed") is executable. Copy an owning context together with its root
migrations, app configuration, dependency constraints and acceptance tests. Do not introduce a Foundry execution layer.

| Use case | Reference and critical invariant |
| --- | --- |
| Authoritative ledger | [RES](../examples/domain-event-sourced-ledger-rails-event-store/README.md "Repository-only reference; not installed"): replay from the stream; integer money and expected versions reject invalid/stale writes |
| Durable jobs | [Sidekiq outbox](../examples/modular-transactional-outbox-postgresql-sidekiq/README.md "Repository-only reference; not installed"): commit intent with state; completion belongs to the database effect, not queue acceptance |
| External vectors | [Qdrant](../examples/modular-multi-tenant-rag-qdrant/README.md "Repository-only reference; not installed"): filter tenant/version/deletion and recheck authoritative revisions before citations |
| Ordered integration events | [Kafka/Karafka and NATS](../examples/modular-event-pipeline-kafka-karafka/README.md "Repository-only reference; not installed"): stable IDs, schema versions, per-key sequence, commit before acknowledgment and durable poison quarantine |
| Concurrent reads | [GraphQL/Falcon](../examples/modular-graphql-async-dataloader/README.md "Repository-only reference; not installed"): explicit tenant/role batch keys, fiber isolation and scoped connection cleanup |
| Separate frontend | [Next.js/GraphQL](../examples/rails-native-nextjs-graphql/README.md "Repository-only reference; not installed"): Rails owns data/auth; frontend owns UI and an independently locked build |
| Persistent AI | [Chat](../examples/rails-native-ai-chat-rubyllm-hotwire/README.md "Repository-only reference; not installed"): distinguish partial failures from completed history and stream escaped text |
| Agent tools | [Authorized tools](../examples/rails-native-agent-tools-structured-output-rubyllm/README.md "Repository-only reference; not installed"): recheck current permission at execution and validate structured references against authoritative state |

Core Rails/packs/native operations and optional RubyLLM remain the foundational tier. PostgreSQL, Redis/Sidekiq,
pgvector, OpenSearch, RabbitMQ, RES and Kafka/NATS recipes have local integration evidence. Qdrant, async/Falcon
and frontend combinations are advanced: their own pinned bundles and stated limits define support. ROM/DI and experimental Pinecone/Weaviate recipes are documented in [advanced composition](advanced-composition.md). See [compatibility](compatibility.md) for tested versions.

Keep workloads independent from architecture settings. These examples demonstrate correctness mechanics;
choose caching, replicas, partition counts, queue concurrency, vector indexes and worker pools from measured demand.
The [evidence recipe](../recipes/evidence/README.md "Repository-only reference; not installed") records controlled runtime samples and a separate agent/onboarding protocol.
