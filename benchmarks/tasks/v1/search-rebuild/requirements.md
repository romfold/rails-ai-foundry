# Rebuild search after updates and deletion

Knowledge::RebuildSearch must build a separate candidate using the injected index protocol, catch up document changes made by after_backfill, and validate exact current published rows (id, tenant_id, body, revision) before activate. Updates, withdrawals, deletions and new publications during backfill must be reflected; unpublished rows must not appear. Final authoritative snapshot, validation and activation use a bounded local write transaction. Failed validation or transport must leave the active index unchanged. A fresh retry after failure must recover using a new candidate. Keep call(index:, after_backfill:) and index create_candidate/replace/valid?/activate protocol. The fixture transport is deterministic; do not add external services.

Do not change dependency versions, visible tests, task instructions or disable verification. Add focused tests for your changes. Normal tests remain offline.
