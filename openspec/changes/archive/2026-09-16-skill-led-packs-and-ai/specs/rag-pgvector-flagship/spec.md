## ADDED Requirements

### Requirement: Safe retrieval adaptation evidence
The existing RAG flagship SHALL offer Neighbor retrieval alongside SQL, sharing tenant/version/deletion/citation acceptance. Re-embedding SHALL refuse stale document revisions after provider work outside transactions. Offline evidence SHALL cover ingestion idempotency, unavailable providers, exact retrieval and bounded approximate retrieval comparison. Application instrumentation SHALL report latency, lag and failures without prompt content or sensitive tenant data.

#### Scenario: Document changes during embedding
- **WHEN** source content changes after it was read for embedding and before persistence
- **THEN** stale embeddings do not replace current passage data

#### Scenario: Switch retrieval implementation
- **WHEN** either supported implementation retrieves the same tenant/version dataset
- **THEN** the shared correctness suite proves isolation and valid citations
