# Implementation plan

Read config/foundry.yml and packs/catalog/foundry.yml for installed architecture.

SaveProduct is a native Dry::Operation with a savepoint and explicit failure rollback. Outbox dispatch holds one SKIP LOCKED row through bounded network I/O. OpenSearch external_gte versions and retained tombstones make stale and duplicate deliveries safe. RebuildSearch takes a final complete catch-up pass under a shared writer gate before validation and alias cutover. This intentionally pauses writes during the final pass; a larger corpus needs a durable change cursor and a shorter cutover fence.

Use the independently locked bundle and compose.yml services. Keep Foundry out of production execution. Reconcile this plan with acceptance evidence when requirements change.
