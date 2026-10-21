# Multi-tenant Qdrant knowledge

A tenant can ingest documents and obtain extractive answers with authorized citations.
Search filters tenant, embedding version and deletion before ranking. PostgreSQL rechecks ownership and revision
before returning evidence, so stale/deleted documents never become citations.
Rebuild creates a candidate, backfills, catches up under the writer gate, validates content/vectors and swaps aliases.
Previous collections remain available for recovery; invalid candidates cannot replace the active alias.
Provider failures preserve authoritative documents, and a subsequent rebuild recovers retrieval.
Offline relevance tests verify refund/shipping topic ordering without asserting production model quality.
