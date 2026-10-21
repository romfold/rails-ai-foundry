# Data and messaging recipes

The 0.3 and 0.4 recipes are application-owned, executable code in standalone Rails applications.
Copy and adapt the owning context with its migration, tests and pinned dependencies; there is
no Foundry outbox, projection, vector or messaging execution runtime.

| Recipe | Executable owner | Evidence |
| --- | --- | --- |
| PostgreSQL transactional outbox | [Catalog](../examples/modular-opensearch-cqrs/packs/catalog/app/commands/catalog/save_product.rb "Repository-only reference; not installed") and [dispatcher](../examples/modular-opensearch-cqrs/packs/catalog/app/services/catalog/deliver_outbox.rb "Repository-only reference; not installed") | [Rollback, crash, poison and concurrent claims](../examples/modular-opensearch-cqrs/test/outbox_test.rb "Repository-only reference; not installed") |
| pgvector ingestion and retrieval | [Knowledge](../examples/rails-native-rag-pgvector/README.md "Repository-only reference; not installed") | [Tenant/version/deletion and retrieval evaluation](../examples/rails-native-rag-pgvector/test/retrieval_test.rb "Repository-only reference; not installed"), [answer contract](../examples/rails-native-rag-pgvector/test/answer_test.rb "Repository-only reference; not installed") |
| OpenSearch CQRS | [Catalog](../examples/modular-opensearch-cqrs/README.md "Repository-only reference; not installed") | [Backfill, catch-up, validation, cutover and recovery](../examples/modular-opensearch-cqrs/test/search_test.rb "Repository-only reference; not installed") |
| RabbitMQ voice control | [Voice](../examples/modular-realtime-voice-rabbitmq/README.md "Repository-only reference; not installed") | [Broker recovery](../examples/modular-realtime-voice-rabbitmq/test/broker_test.rb "Repository-only reference; not installed"), [bounded media and interruption](../examples/modular-realtime-voice-rabbitmq/test/media_test.rb "Repository-only reference; not installed") |
| Incremental package extraction | [Legacy adoption](../examples/modular-legacy-adoption-packwerk/README.md "Repository-only reference; not installed") | [Disposable extraction and no-new-debt check](../examples/modular-legacy-adoption-packwerk/script/verify_adoption.rb "Repository-only reference; not installed") |

## Transactions and dispatch

Persist business state and intent on the same Active Record connection in the same transaction.
A native Dry::Operation failure explicitly rolls back its savepoint, including when called
inside another transaction. A successful operation is still provisional until the outer
transaction commits. Never publish externally from the write transaction or an after-commit
callback that is the only record of required work.

Dispatch locks one due row using `FOR UPDATE SKIP LOCKED`, sends through the upstream client,
then marks delivery. A process can die between send and acknowledgment: this is at-least-once
publication, so consumers require stable identities and idempotent effects. A broker confirm
establishes broker acceptance, not successful consumer business work. Receipt and business
effect commit together before manual acknowledgment.

These bounded examples retain a row lock and database connection through network I/O. Configure
short timeouts and a worker count that fits the connection pool. Monitor pending age, oldest
undelivered intent, retry counts and poisoned work. Do not reset retries automatically or
blindly replay malformed messages. Repair the cause, review the selected identity, then replay.
The [dedicated PostgreSQL/Sidekiq app](../examples/modular-transactional-outbox-postgresql-sidekiq/README.md "Repository-only reference; not installed") keeps intent pending until its database effect acknowledges completion, recovering even a lost Redis job. ROM's later recipe
must persist both state and intent through the same ROM gateway transaction.

## Derived data and cutover

Search and embeddings are derived from authoritative documents or products. Search retains
soft-deletion tombstones and uses external revision ordering. Backfill a candidate index, catch
up, validate all content, then swap the read alias atomically. Leave the old index until reviewed
cleanup; rebuild from PostgreSQL rather than treating the index as business truth.

The search flagship uses a final full pass under a writer gate. This makes its race handling
explicit and testable, but pauses writes while that pass runs. Scale it using a durable change
cursor and a shorter cutover fence only after measuring the workload. Exact tenant-filtered
pgvector search similarly favors correctness for a bounded corpus; adopt approximate search
with measured recall and tenant-isolation evidence.

RAG versions identify the embedding model and chunking contract. Never change their meaning in
place. Reembed a complete document version atomically, route reads to a verified version, and
remove every version on deletion. Citation identity checks cannot establish semantic truth.
The offline deterministic evaluation demonstrates the harness and isolation, not model quality.

The [updated pgvector flagship](../examples/rails-native-rag-pgvector/README.md "Repository-only reference; not installed") also demonstrates
Neighbor 1.2.0, tenant/source-key deduplication and optimistic revision fencing. Both readers reject
stale passage revisions. Its exact/ANN comparison verifies an actual HNSW plan under disclosed
test-local planner controls; it does not prescribe those settings for production. Application-owned
notifications measure duration/status and index lag without content payloads. Start with the
[RAG adaptation skill reference](../skills/references/rag.md) before copying persistence or provider code.

## Voice and deployment

A session epoch fences current work. Interruption clears buffered media and advances the epoch;
reconnection starts idle. Both server and client must reject stale media, because the server
cannot retract audio already in flight. RabbitMQ carries control only. The example's bounded
HTTP PCM transport can be replaced by WebRTC without moving authority into the media process.

Compose configurations are local acceptance infrastructure with loopback ports. They are not
production deployment templates. Keep authentication, secret management, TLS, monitoring,
retention, broker access policies and capacity limits application-owned. Ordinary application
writes remain synchronous; durable async work is chosen for projection and control delivery.

The complete [0.4 integration recipes](integration-recipes.md) add Qdrant, RES, Kafka/NATS, async GraphQL/Falcon, native AI and a Rails-root frontend.
