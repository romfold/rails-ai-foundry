# Adapt the RAG worked example

Use for ingestion, retrieval or evidence-grounded answers. Start from the existing rails-native-rag-pgvector example's README, locked bundle, focal foundry.yml and tests when its source is available. The full example is intentionally excluded from the installed gem; locate the project example checkout or use its documented source, and do not claim to have inspected unavailable code.

Plan the owning context and requirements before copying code. Keep business authorization and tenant selection in application code; never accept a tenant chosen by a prompt or tool argument without authorization. Decide the authoritative documents, revision identity, deletion semantics, embedding model/version/dimensions, chunk boundaries and citation contract. Select SQL or Neighbor retrieval explicitly against the app's locked pgvector combination; the worked example's acceptance determines verified support.

Implement provider work outside database transactions. Recheck the source revision under lock before storing embeddings, make ingestion repeatable, retain recoverable failure state and reject unavailable providers explicitly. Filter tenant, version and deletion before ranking/limiting results. Return citations that identify an authorized source revision and passage, then validate answers independently of prompt wording.

First run deterministic offline tests for relevant/irrelevant documents, cross-tenant similarity, stale revisions, duplicate ingestion, deletion, provider failure and citation validity. Compare exact and approximate retrieval using a fixed corpus, recall and bounded query settings; report observed results and limits rather than assuming ANN improves every workload. Instrument latency, indexing lag and failures without logging prompt text or sensitive identifiers.

Keep the example as evidence and adapt only necessary behavior. No capability generator or Foundry retrieval runtime is required. New dependencies and configuration changes need a visible diff. Read [AI conventions](ai.md) when agents/tools are involved; live evaluations require explicit model selection, credentials and budgets and remain outside normal tests.
