# Experimental external vectors

Pinecone and Weaviate are explicitly experimental. These small application-owned HTTP recipes provide protocol boundaries, not a common Foundry vector runtime or an ANN performance claim. The advanced Qdrant and mainstream pgvector examples remain the fuller RAG references.

```sh
cd recipes/experimental-vectors
bundle _2.6.9_ install
bundle exec ruby test/contracts_test.rb
docker compose up -d
WEAVIATE_ACCEPTANCE=1 bundle exec ruby test/weaviate_service_test.rb
bundle exec rubocop
docker compose down -v
```

Wait for http://127.0.0.1:58080/v1/.well-known/ready before the service test. Normal contract tests use WebMock with all network disabled. Service acceptance only permits the loopback Weaviate port and uses unique collections removed after the test. Compose anonymous access is for this disposable loopback service only; production Weaviate authentication and credentials must be added at the application's HTTP boundary.

Construct Scope from the authenticated actor's tenant, installed embedding version and selected serving generation. Do not accept those identities directly from an agent tool's arguments. A SHA-256 digest of the unambiguous tuple is the Pinecone namespace and Weaviate physical tenant, isolating versions as well as tenants for upsert, search and deletion. Weaviate additionally filters the exact embedding version. The demonstration accepts finite three-dimensional vectors and positive revisions; select dimensions with your real embedding model and recreate incompatible generations.

PineconeIndex uses the upstream 2025-04 vector API contract with a supplied index endpoint and API key. Its namespace and version-filtered top-five query, upsert and deletion are verified offline. No Pinecone account was contacted and no live Pinecone compatibility or quality result is claimed. Weaviate 1.36.6 has real local service evidence for tenant/version isolation, update and deletion. HTTP failures, malformed responses and failed batch items surface as ProviderError, without automatic retries. Experimental support does not imply arbitrary cloud deployment compatibility.

[Citations](lib/citations.rb) rechecks authoritative tenant, embedding version, deletion and revision before returning document text. Supply a tenant-filtered application database lookup; stale index content is never the citation authority. The provider is not responsible for application authorization.

Rebuild procedure: create a fresh generation; snapshot source revisions; backfill in bounded batches; retain a change log; catch up changes including tombstones; pause writers briefly or use a proven sequence barrier; validate IDs, tenant/version scope and retrieval fixtures; atomically switch the application-owned serving-generation pointer. Keep the previous pointer and generation until the recovery window closes. On validation or provider failure do not switch. Roll back the pointer if validation after cutover fails, then replay missed changes before retry. Delete/tombstone in the source first; eventual index deletion must not expose stale citations. The Qdrant example contains executable backfill/catch-up/cutover mechanics to adapt; these experimental clients do not claim a cloud-wide atomic index swap.

Protocol references: [Pinecone query](https://docs.pinecone.io/reference/api/2025-04/data-plane/query), [Pinecone consistency and data modeling](https://docs.pinecone.io/guides/index-data/data-modeling), [Weaviate multi-tenancy](https://docs.weaviate.io/weaviate/manage-collections/multi-tenancy), [Weaviate APIs](https://docs.weaviate.io/weaviate/api).
