# Modular OpenSearch CQRS

The focal context is [Catalog](packs/catalog/foundry.yml); topology is in its adjacent
[package.yml](packs/catalog/package.yml). [Root defaults](config/foundry.yml) select the workflow.

Ordinary synchronous Rails writes commit products and outbox intent in one PostgreSQL transaction.
Search is a rebuildable read model. No Foundry-owned event or projection runtime is involved.

## Try it

```sh
curl -X POST http://localhost:3000/products -H 'Authorization: Bearer local-editor' -H 'Content-Type: application/json' -d '{"name":"Oak desk"}'
bin/project rebuild
curl 'http://localhost:3000/products?q=desk'
bin/project drain
```

Set `EDITOR_TOKEN` outside the local demo. Reads are public product catalog queries; writes
require the token. `bin/project drain` processes at most 100 currently due entries and exits.
Schedule it repeatedly with your chosen process supervisor; failed attempts become due after
exponential backoff. The app deliberately keeps ordinary writes synchronous.

## Recovery recipe

`SaveProduct` uses native Dry::Operation and an explicit savepoint rollback on failure.
`DeliverOutbox` locks one due intent with `FOR UPDATE SKIP LOCKED`, publishes afterward, then
records delivery. A crash after publication can repeat it. OpenSearch uses the stable product
identifier and `external_gte` revision checks; duplicate delivery has one visible document.
Deletion uses a retained tombstone so old messages cannot resurrect removed search results.

After three failures an entry becomes poisoned. Inspect `last_error` and its payload, fix the
underlying cause, and explicitly call `Catalog::OutboxEntry.find(id).replay!`. Normal dispatch
never resets poison or deletes accepted evidence. Monitor pending age, attempts and poison count.

`bin/project rebuild` backfills a fresh index, catches up under a shared writer gate, validates
all projected content, and swaps the read alias atomically. Previous indexes remain for review.
An interruption before cutover leaves the active alias alone. If the connection fails during
cutover, inspect the alias before cleanup because the server may have completed the swap. Rebuild from PostgreSQL after recovery;
only delete abandoned indexes after checking the active alias. The final full catch-up pass
pauses writers: this is a clear, bounded example, not a high-volume zero-pause rebuild design.
A large deployment needs a durable change cursor, measured catch-up and a shorter cutover fence.
Outbox network I/O has short timeouts but holds a connection and row lock; bound worker concurrency
to available connections. The separately planned Sidekiq example remains a 0.4 deliverable.

Tests exercise real OpenSearch write blocks, failed candidates, duplicate replay, tombstones,
concurrent outbox workers, nested failed results and crashes before acknowledgment.

## Run and verify

Use Ruby 3.4.10 and Bundler 2.6.9. Run every command from this application directory.
Docker Compose v2 is required for the disposable services. PostgreSQL client tools 17
(`psql` and `pg_dump`) must be on PATH for SQL schema loading in the RAG application.

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
