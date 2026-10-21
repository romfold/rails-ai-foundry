# Tenant knowledge application

Status: locally verified; hosted CI pending. This living behavioral contract references
`config/foundry.yml`, each `packs/*/foundry.yml` and upstream `package.yml` files for
architectural configuration. It does not duplicate the dependency graph.

- Authenticated tenants can create, edit, publish, withdraw and delete their documents.
  Stale revisions fail without modifying data. Other tenants cannot view or mutate them.
- Document changes and publication intent commit together. Failed native operation
  results and nested failures roll back the appropriate transaction or savepoint.
- Delivery remains recoverable after process failure. A stable event identity is
  acknowledged only when its RES payload and stream agree with the publication intent.
  Search and vector destinations have independent leases, retries and quarantine.
- Search, retrieval and citations use current published revisions authorized for the
  caller. Withdrawal and deletion apply immediately even before projections catch up.
- Embedding and answer providers execute outside writer transactions. Obsolete results
  are rejected. Normal execution and acceptance use deterministic offline providers.
- Tenant document pages use keyset pagination (50 by default, maximum 100) and fetch
  only their delivery status. Exact retrieval filters tenant/version in SQL, orders
  distance then ID, checks at most 100 candidates and returns up to five current documents
  with an explicit incomplete flag. Citation validation remains authoritative.
- Document mutation history commits with business state and outbox intent. Linked journal
  entries plus the writer gate establish fences without treating sequences as commit order.
- Rebuilds persist candidate identity, finite scan bounds, checkpoints, paged manifests,
  leases and retry/quarantine state. Batches contain at most 250 records and Elasticsearch
  bulk requests at most 1 MiB. Lost scheduling and process death cannot erase pending work.
- Pre-cutover validation failure preserves the active selection. Paged identity/revision/
  content validation and journal replay cover concurrent creation, updates and tombstones.
  Final activation contains no full scan or provider call. Vector selection is transactional.
- Elasticsearch cutover intent precedes a guarded alias action. An unknown outcome freezes
  candidate work and cleanup until actual selection is reconciled; never blindly revert.
  Post-fence changes reach the confirmed destination before completion. Operator cleanup
  defaults to preview and refuses active, leased or unresolved candidates.
- Rails HTTP delivery displays document and indexing state. Queue wake-ups are not the
  authoritative record of pending work.

Demo bearer tokens are explicit local authentication examples, not production identity.
Provider model quality and deployment availability are outside offline acceptance.
