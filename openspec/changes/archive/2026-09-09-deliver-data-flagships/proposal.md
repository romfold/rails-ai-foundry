## Why

The native core is verified, but consumers still lack executable data recipes and reference applications. The approved 0.3 milestone supplies four flagships without restoring a Foundry execution runtime.

## What Changes

- Deliver independently bundled legacy-adoption, pgvector RAG, OpenSearch CQRS and RabbitMQ voice applications.
- Add application-owned transactional outbox, data/index recovery and messaging recipes with correctness tests.
- Add a location/focal-context catalog, application-specific workflow artifacts and independent CI.
- Keep unfinished integrations explicit and retain the 0.2 core compatibility floor.

## Capabilities

### New Capabilities

- `legacy-adoption-flagship`: incremental extraction with behavior parity and preserved upstream debt.
- `transactional-outbox-recipe`: atomic publication intent and recovery from delivery crashes.
- `rag-pgvector-flagship`: tenant-scoped ingestion, retrieval, citations and embedding lifecycle.
- `opensearch-cqrs-flagship`: rebuildable search projections with safe cutover and recovery.
- `rabbitmq-voice-flagship`: separated voice control/media responsibilities and reliable messaging.
- `example-catalog`: descriptive names and configuration-derived focal context verification.

### Modified Capabilities

None. The initial delivery consumes existing native APIs.

## Impact

Examples, recipe guidance, optional dependencies and CI. No new core application runtime or production dependency is introduced. Each example owns its bundle and infrastructure. The repository keeps OpenSpec; new-app examples use Spec Kit and the adoption example uses OpenSpec. Publishing remains separate.
