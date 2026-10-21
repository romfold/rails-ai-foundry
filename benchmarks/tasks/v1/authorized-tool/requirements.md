# Add an authorized retrieval tool

Implement trusted tenant-scoped retrieval in Answering::RetrievalTool. Call the injected authorizer with the constructor tenant before retrieving anything; deny with SecurityError when false. An optional model-supplied tenant_id must equal the trusted tenant or be rejected with SecurityError. Return only that tenant's currently published documents whose body includes query, using Knowledge::Catalog. Keep signatures and ordering. Never trust model arguments as authorization. No live model calls.

Do not change dependency versions, visible tests, task instructions or disable verification. Add focused tests for your changes. Normal tests remain offline.
