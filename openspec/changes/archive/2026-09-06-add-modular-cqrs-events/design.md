## Context

The MVP runtime supplies dry-operation results, explicit dry-system composition, owned Active Record models, and conservative component receipts. Rails Event Store 3.1 is installed only in dedicated consumer/event test bundles.

## Goals / Non-Goals

Deliver local synchronous transactional publication and read-only queries. Distributed jobs, outboxes, provider requests, event-sourced aggregates, and projections remain separate changes.

## Decisions

Command overrides the operation steps boundary with a unit of work so dry-operation catches failures before transaction completion. Query guards the same boundary using Active Record preventing-writes. The unit of work uses requires_new transactions and rolls back failure results explicitly.

A plain Ruby immutable Event holds type/version constants, UUID event_id, data, and metadata. A codec uses an explicit contract registry, not constantize on stored data. It maps immutable contracts to mutable RubyEventStore envelopes because upstream enriches metadata. A small mapper converts envelopes to RubyEventStore records; the Active Record repository uses JSON serialization. A RailsEventStore client uses an explicit synchronous broker. The scoped package bus verifies event ownership and stream prefixes. Subscription registration verifies manifest dependency direction and public event namespaces.

Composition subclasses declare event_contracts and subscribe(events, container). Runtime prepare first loads these contracts, builds a fresh store when the event initializer enables it, then builds containers and subscriptions. Reload replaces the store and all handlers. Event installation requires the gem already present, emits exact dependency guidance otherwise, creates its own schema migration and initializer with a receipt, and never runs bundle or database migration automatically. One database and connection pool is supported.

## Risks / Trade-offs

External side effects cannot be rolled back; generated guidance prohibits them in synchronous handlers. The single-database contract excludes separate model connections. JSON event contracts require explicit version migration; unknown versions fail instead of guessing. Dynamic calls cannot be fully statically checked.

## Migration Plan

Add rails_event_store ~>3.1.0 to the consumer, bundle, generate foundry:events, review and run host migrations, then enable package loading. Existing initializers and migrations are preserved on repeat. Disable event initialization to roll back runtime adoption; do not delete stored events.
