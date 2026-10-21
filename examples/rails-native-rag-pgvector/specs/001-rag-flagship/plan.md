# Implementation plan

Read config/foundry.yml and packs/knowledge/foundry.yml for installed architecture.

PostgreSQL pgvector stores 1536-dimensional passage vectors. The default SQL reader materializes tenant/version/current-revision distances before exact ranking. Neighbor 1.2.0 supplies an alternate native Active Record reader and the HNSW cosine index. Acceptance forces and verifies an actual index plan, measures bounded recall and discloses every local planner control.

A unique tenant/source key deduplicates ingestion. Active Record optimistic locking versions documents; a passage records the revision used to embed it. Provider work precedes local transactions, then reembedding locks and compares the source revision before replacing passages atomically. Concurrent source edits reject stale work; both readers exclude stale revisions. An application adding direct SQL writes must advance the revision explicitly.

DemoEmbeddings and EvidenceAnswer support local operation; ProviderEmbeddings and ProviderAnswer use direct RubyLLM with constructor injection. The prompt contract lives at packs/knowledge/app/prompts/knowledge/answer/. Active Support notifications report duration/status and index lag with content-free payloads.

Use the independently locked bundle and compose.yml services. Keep Foundry out of production execution. Reconcile this plan with acceptance evidence when requirements change.
