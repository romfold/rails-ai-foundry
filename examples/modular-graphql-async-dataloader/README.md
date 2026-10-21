# Modular GraphQL with AsyncDataloader

The focal context is [directory](packs/directory/foundry.yml). This standalone app uses direct GraphQL
AsyncDataloader, Rails fiber isolation and an optional Falcon server, with no Foundry production runtime.

```sh
docker compose up -d --wait
bundle install
bin/setup
bin/verify
bundle exec rubocop
bundle exec falcon serve --bind http://127.0.0.1:3000 --count 1
```

POST `/graphql` with `Authorization: Bearer demo-a` and JSON query
`{ people(ids: [1, 2]) { name manager { name } } }`. Demo-b sees another tenant.
Unknown or cross-tenant IDs return null. Replace demonstration bearer identities with real authentication.

The source takes trusted tenant and database role as batch keys. Manager lookups batch across parent records.
Each source scopes Current, connected_to and with_connection(prevent_permanent_checkout: true), including error paths.
Rails uses fiber isolation; never assume thread-local identity automatically survives scheduler boundaries.
The local reading role points to the same PostgreSQL database and prohibits writes. This verifies role propagation,
not physical replication. Production can supply READ_DATABASE_URL; account for replica lag explicitly.

Acceptance checks nested batching, multiplex isolation, concurrent database I/O, no leaked read connections,
source failure recovery and actual Falcon HTTP delivery. Timing is not a production throughput benchmark.
Falcon 0.51.1 requires the explicitly pinned traces 0.18.2 with the resolved async dependency set.
Puma remains available. The advanced bundle does not raise Foundry's core compatibility floor.

Keep [living behavior](specs/001-reference/spec.md), plan and tasks reconciled. Spec Kit checks artifacts;
actual database/server tests provide behavioral evidence. Use bounded queries and size connection pools against
real concurrency before deployment.
