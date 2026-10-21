# Modular transactional outbox with PostgreSQL and Sidekiq

The focal context is [orders](packs/orders/foundry.yml). This independent app uses direct Rails transactions,
Dry::Operation and Sidekiq jobs. Foundry is development-only.

```sh
docker compose up -d --wait
bundle install
bin/setup
bin/verify
bundle exec rubocop
bin/rails server
# In another terminal:
bundle exec sidekiq -r ./config/environment.rb -q foundry_orders -c 2
# Run periodically from your scheduler:
bundle exec ruby packs/orders/script/dispatch.rb
```

POST `/orders` with `Authorization: Bearer demo-a` and JSON `cents: 100`. A 201 response means the ordinary
order write committed; GET `/orders/:id` reports placed or fulfilled. Replace demonstration identities with real authentication.
The dispatcher drains up to 100 due intents per invocation; schedule it repeatedly for continuous delivery.

Order and intent share one PostgreSQL transaction. Dispatch uses SKIP LOCKED; queue acceptance leaves the
intent pending and due again after ten seconds until the worker commits a unique receipt, effect and completion.
A lost Redis job or crash after publish is recovered by redispatch. Duplicate jobs are harmless under the outbox lock.
Redis AOF is enabled in Compose, but PostgreSQL intent still determines completion. This is at-least-once delivery.
Malformed envelopes are quarantined; inspect last_error, repair payload and call entry.replay! explicitly.
Unexpected transient worker errors use Sidekiq retries and retained intent. Watch pending age, attempts and poison counts.
External effects require their own idempotency keys; this example's effect stays inside PostgreSQL.

Pin connection_pool 2.5.5 with Sidekiq 7.3.9: the unconstrained 3.x resolution breaks Sidekiq's scheduler.
Tests use Redis database 11 and only disposable loopback PostgreSQL. `bin/verify` also starts and stops a real worker.
The crash/loss/duplicate/poison tests are correctness evidence, not throughput benchmarks.
Keep [the contract](specs/001-reference/spec.md), plan and tasks reconciled when behavior changes.
