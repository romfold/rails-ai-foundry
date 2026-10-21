# Rails-native RAG with pgvector

The focal context is [Knowledge](packs/knowledge/foundry.yml); topology is in its adjacent
[package.yml](packs/knowledge/package.yml). [Root defaults](config/foundry.yml) select the workflow.

This is an executable tenant-scoped retrieval and answer application. Documents split into
paragraphs; PostgreSQL stores 1536-dimensional embeddings with explicit versions. SQL filters
tenant, embedding version and current document revision before exact cosine ranking.
Neighbor offers a second, application-owned retrieval path. Deletion cascades to all versions.
The default embedding model is a transparent deterministic topic vocabulary and answers quote
retrieved evidence. This makes the complete demo runnable without an API key.

## Try it

```sh
curl -X POST http://localhost:3000/documents -H 'Authorization: Bearer demo-a' -H 'Content-Type: application/json' -d '{"title":"Refund policy","body":"Return money within 30 days for a refund."}'
curl 'http://localhost:3000/answer?question=refund' -H 'Authorization: Bearer demo-a'
curl 'http://localhost:3000/search?question=refund' -H 'Authorization: Bearer demo-b'
curl -X DELETE http://localhost:3000/documents/1 -H 'Authorization: Bearer demo-a'
```

The second tenant gets no evidence from the first. Replace `TENANT_TOKENS` with a JSON
mapping from secret bearer tokens to tenant identifiers outside the local demo. A request's
tenant parameter is never authoritative. Token authentication substitutes for a real identity
provider in this example; a product should resolve the same tenant from its authenticated session.

## Embedding and answer lifecycle

`Knowledge::Ingest.new(version: 'demo-v2').reembed(tenant_id: 'tenant-a', id: id)` writes a
complete version atomically and can safely repeat. Readers explicitly choose the matching
version. Never reuse a version identifier for a different model or chunking configuration.
Ingestion accepts an optional `source_key` in the Ruby API; its default is a digest of title and
body. A tenant/key uniqueness constraint prevents duplicate documents on repeat ingestion.
Reusing a key with different content fails explicitly. Repeats can call the embedding provider
again, but replace passages atomically. This does not promise exactly-once provider billing.

Documents use Active Record optimistic locking. Updating content through `Document#update!`
advances `lock_version`; the public HTTP demo does not expose an update endpoint. Reembedding
captures that revision before provider work, then rechecks it under a row lock. Concurrent edits
reject stale results. Both readers omit stale passages until the new revision is embedded.
Provider work happens outside the transaction opened by ingestion; callers must also avoid
wrapping the service in their own transaction. Direct SQL writes must advance `lock_version`
and maintain `updated_at` explicitly. Older rows without a source key must be assigned one before
using key-based repeat ingestion; this example performs no automatic business-data conversion.

Native `Knowledge::ProviderEmbeddings` and `Knowledge::ProviderAnswer` are opt-in constructor
adapters using RubyLLM directly. Application-owned aliases live in [config/ai.yml](config/ai.yml);
the pack-local [prompt contract](packs/knowledge/app/prompts/knowledge/answer/contract.yml) describes evidence handling.
The default HTTP endpoints remain offline. Tests inject providers and verify failures explicitly;
there is no live evaluation runner. Choose matching 1536-dimensional embeddings and a fresh
version before using a real model. Operational live evaluation requires separate explicit
credentials, model selection and request/token/time/spend limits.

`Answer` rejects unknown citation identifiers. This validates evidence identity, not semantic
truth: production RAG still needs domain-specific evaluation and human review. The small
checked-in test corpus measures deterministic recall@1, including irrelevant and cross-tenant
documents; it does not claim production model quality.

`Knowledge::Retrieve` materializes filtered distances before ranking, keeping the default HTTP
path exact even with an HNSW index installed. `Knowledge::NeighborRetrieve` uses Neighbor 1.2.0
and native Active Record relations with the same tenant/version/revision predicates. Its query
can use the HNSW cosine index; normal planner choice depends on data and statistics. Approximate
search can return fewer filtered neighbors and tie ordering may differ from exact SQL. Measure
recall for real tenant distributions before switching readers.

The bounded ANN test uses 240 synthetic 1536-dimensional vectors, seed 41, five queries and k=5.
It checks the actual query's EXPLAIN plan for the HNSW index, compares with exact SQL, and emits
the conditions and recall. Test-local settings force index order, disable sort/sequence scans,
set `hnsw.ef_search=64`, strict iterative scanning, 1000 scan tuples and a two-second statement
timeout. These settings are rolled back; they are not application defaults or throughput evidence.
The verified local recall is 1.0 for this corpus only.

`Knowledge::Telemetry` emits `knowledge.ingest`, `knowledge.reembed`, `knowledge.retrieve_sql`
and `knowledge.retrieve_neighbor` durations/status, and `knowledge.indexed` lag since the document's update. Payloads omit tenants,
questions, documents, vectors, credentials and exception messages. Subscribe with ordinary
Active Support notifications. Index lag measures this local passage update, not a durable queue.
Results carry `document_revision` alongside citation identifiers; the example does not retain
historical document revisions for permanent citation replay.

PostgreSQL SQL schema format preserves the pgvector custom type. Neighbor casts model vector
attributes to arrays; the exact SQL path encodes bound values. Vectors are dimension/finite/nonzero
validated before insertion and querying.

## Run and verify

Use Ruby 3.4.10 and Bundler 2.6.9. Run every command from this application directory.
Docker Compose v2 is required for the disposable services. PostgreSQL client tools 17
([official Ubuntu packages](https://www.postgresql.org/download/linux/ubuntu/): `psql` and `pg_dump`) must be on PATH for SQL schema loading in the RAG application.

```sh
bundle install
docker compose up -d --wait
bin/setup
bin/verify
bundle exec rubocop
bin/rails server
```

Services bind to loopback only. The default PostgreSQL port is 55432. If another example
is already using it, run with a distinct `PGPORT` for both Compose and Rails, or reuse a
compatible disposable service explicitly. Each application has a distinct database name.
`docker compose down -v` removes only this Compose project's disposable services and data.
Never point these acceptance commands at a production database.

`bin/verify` runs real integration tests, source diagnostics, upstream Packwerk,
Spec Kit artifact prerequisites, and production eager loading without Foundry execution.
Normal tests permit loopback services only; no model credentials or provider requests are needed.
The independent CI lane uses the same commands and locked Linux dependencies.
Remote CI execution is separate from the local evidence reported here.

## Specification workflow

Pinned upstream Spec Kit 1.0.0 initialized this app. Its installed skills and scripts are
checked in; running this Rails application needs no Python or Spec Kit runtime.
For workflow changes, install Python 3.11+ and the pinned Specify CLI as described in
[Foundry workflow setup](../../docs/core-workflow.md).
Read the application constitution, living spec, plan, tasks and reconciliation evidence.
Upstream prerequisite checks establish artifact presence; they do not validate behavior.
