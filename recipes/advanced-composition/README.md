# Optional ROM composition

This recipe demonstrates a real persistence boundary with direct ROM SQL, a native Dry::Operation result and one ROM gateway transaction. It is not a mandatory repository layer for Active Record.

```sh
cd recipes/advanced-composition
bundle _2.6.9_ install
docker compose up -d --wait
bundle exec ruby test/composition_test.rb
bundle exec rubocop
docker compose down -v
```

The disposable database is restricted to loopback and the name foundry_composition_test. Database.prepare creates recipe tables only there. In an application, put the schema changes in root migrations and Billing classes in the owning pack; initialize the ROM container at the application's composition root. The standalone recipe does not install a second Rails loader.

[PlaceOrder](lib/place_order.rb) writes orders and outbox intent through the same gateway. An explicit savepoint rollback handles failed native operation results, including failure inside an outer transaction. A surrounding rollback also removes successful nested writes. No external publication occurs in the write transaction. Efficient reads may query ROM relations or optimized Active Record directly; do not reconstruct write entities merely to render a read.

[Dispatch](lib/dispatch.rb) rejects dispatch inside an active writer transaction and locks committed pending intent with SKIP LOCKED, delivers its stable event ID, then records acknowledgment. The test destination commits independently and deduplicates IDs. A crash after destination commit leaves intent pending and replay produces one destination effect. A failed provider call also leaves intent pending. Invalid amounts are quarantined; explicit repair and setting status back to pending permits replay. A scheduler owns polling/backoff and operational alerting. This bounded recipe holds a lock during delivery; use timeouts and a lease design if long-running destinations justify the complexity. Do not claim exactly-once transport.

For RES delivery, use the intent event_id as the upstream event ID and preserve a destination receipt/conflict policy before acknowledgment. An RES client using another connection cannot share the ROM transaction by virtue of pointing at the same database. Deliver after the ROM commit; authoritative stream concurrency still belongs to RES expected versions (see the ledger example). This recipe verifies an independent database destination; it does not claim a distributed ROM/RES transaction.

[Composition](lib/composition.rb) shows explicit dry-system registration and finalization. Construct PlaceOrder directly by default; the optional container merely wires constructor arguments and keeps request authorization out of global mutable state. In a reloadable Rails development environment rebuild wiring in Rails.application.reloader.to_prepare; never cache reloadable class instances across reloads. Keep connection lifetime and shutdown owned by the app.

Billing::Quote is an independent Trailblazer workflow with its own result/context. It is an opt-in alternative when its step orchestration is useful, not a wrapper around Dry results or a dependency of other apps. Do not add a Foundry base operation or container.

Verified: rom-sql 3.7.0 / rom 5.4.3, dry-system 1.2.5, trailblazer-operation 0.11.1, PostgreSQL 17.11. Load dry/system before dry/system/container; direct container-only loading fails on the tested version. Seven tests cover 30 assertions with real PostgreSQL and no Foundry runtime loaded.

Upstream references: [ROM transactions](https://rom-rb.org/3.0/learn/sql/transactions/), [dry-system container](https://github.com/dry-rb/dry-system/blob/main/lib/dry/system/container.rb), [Trailblazer operations](https://trailblazer.to/2.1/docs/operation/). Tested source and locks, rather than historical documentation alone, establish this recipe's concrete compatibility.
