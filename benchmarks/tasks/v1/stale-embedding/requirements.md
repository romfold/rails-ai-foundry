# Reject stale embedding results

Knowledge::EmbeddingJob must avoid storing stale or unauthorized results. Read a tenant-scoped published snapshot, invoke provider.call(body) outside any database transaction, then recheck authoritative existence, tenant, publication state and revision before atomically storing an embedding for document/version. Return :discarded if initially unavailable or changed while the provider runs, otherwise :stored. A revision update, withdrawal, deletion or tenant reassignment during the provider call must leave no stale new embedding. Do not overwrite a newer embedding with an older result. Different embedding versions coexist. Provider errors propagate without writing. Keep public signatures and ordinary Rails execution.

Do not change dependency versions, visible tests, task instructions or disable verification. Add focused tests for your changes. Normal tests remain offline.
