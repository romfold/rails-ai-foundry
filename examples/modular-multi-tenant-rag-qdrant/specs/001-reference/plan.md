# Plan

Follow installed context configuration. Persist UUID documents, versioned embeddings and tombstones in PostgreSQL.
Use direct Qdrant REST calls behind an app-owned external boundary. Retrieve with Qdrant tenant/version/deletion
filters, then verify current PostgreSQL revisions. Compose extractive answers with explicit citations.
Rebuild through fresh collections, paged backfill, a final writer-gated catch-up, vector/content checks and atomic aliases.
Exercise real Qdrant and PostgreSQL, unavailable providers, tenant isolation, version selection, deletion and recovery.
