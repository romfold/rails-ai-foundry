# Domain event-sourced ledger with Rails Event Store

The focal context is [ledger](packs/ledger/foundry.yml), using the domain profile and independent
event_sourced setting. This app has its own bundle and Spec Kit workflow.

```sh
docker compose up -d --wait
bundle install
bin/setup
bin/verify
bundle exec rubocop
bin/rails server
```

Post JSON to `/accounts/cash` with `Authorization: Bearer demo-a`, `cents: 100` and
`expected_version: -1`; read the same URL to obtain balance and version. A later debit uses that version.
`demo-b` owns a separate stream. Demo tokens illustrate ownership; replace them with your application's
identity provider before deployment. Writes are synchronous and return 409 for stale versions.

Balances are replayed from authoritative streams using direct Rails Event Store 3.1 JSONClient;
there is no mutable balance table or Foundry runtime. The migration comes from the upstream generator.
Integer cents avoid floating-point money. The bounded example supports one currency and no transfers.
Append performs persistence only; downstream publication would require a transactional outbox.
No event history is rewritten. For large accounts, introduce verified snapshots without changing authority.

`bin/verify` uses only a disposable loopback `_test` PostgreSQL database, checks loading and Packwerk,
and checks Spec Kit artifacts. Tests establish behavior; the artifact check alone does not.
Keep [the living contract](specs/001-reference/spec.md), plan and tasks reconciled when behavior changes.
Production requires DATABASE_URL and SECRET_KEY_BASE; Foundry remains development-only.
