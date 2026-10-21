## Purpose

Demonstrate tenant-scoped retrieval with reproducible ingestion and trustworthy evidence references.

## ADDED Requirements

### Requirement: Retrieval lifecycle
The application SHALL isolate tenants, version embeddings, remove deleted content, return citations and fail explicitly when providers are unavailable. Offline acceptance SHALL measure retrieval against deterministic relevant and irrelevant documents.

#### Scenario: Cross-tenant similarity
- **WHEN** another tenant owns the closest matching document
- **THEN** retrieval excludes it and cites only authorized available documents
