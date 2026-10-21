# Reconciliation evidence

Verified locally on 2026-09-16 with Ruby 3.4.10 / Rails 8.1.3.1 / Neighbor 1.2.0: 12 tests / 93 assertions, zero failures/errors/skips.

`test/retrieval_test.rb`: tenant filtering, relevant/irrelevant corpus and recall@1, version isolation, reembedding, deletion and provider failures. `test/answer_test.rb`: grounded citation identities, missing evidence, provider failure, native schema and pack-local prompt. `test/delivery_test.rb`: authenticated ingestion, tenant isolation and deletion.

`test/retrieval_lifecycle_test.rb`: shared SQL/Neighbor lifecycle, source-key repeats/conflicts, a source edit during embedding, stale exclusion and recovery, safe notifications. `test/provider_transaction_test.rb` uses nontransactional fixtures to prove provider work precedes the transactions opened by ingestion/reembedding. It does not authorize an outer transaction around these services.

`test/retrieval_evidence_test.rb`: 240 synthetic vectors, 1536 dimensions, seed 41, five queries, k=5, recall 1.0. The actual Neighbor SQL plan includes `knowledge_passages_embedding_hnsw`. Test-only controls: sequence scans and sorting disabled, ef_search 64, strict iterative scanning, max_scan_tuples 1000, statement_timeout 2000 ms. The first attempted evidence run used a B-tree join/sort and correctly failed the ANN-plan assertion; the final test explicitly forces and discloses index order. This is isolation/recall harness evidence, not normal planner choice, throughput or semantic model-quality evidence.

`bin/setup` and `bin/verify` passed with real disposable services, including upstream Packwerk
and pack-local prompt contracts and production eager loading without Foundry execution. The independent `bundle exec rubocop`
passed. Spec Kit 1.0.0 initialized this application, and its own prerequisite script resolves
the application's spec/plan/tasks. This is artifact presence evidence, not a common behavioral validator.

The checked-in CI job runs the same independent bundle and service configuration. Remote CI
was not run. No live provider calls occurred. See README for bounded-demo tradeoffs, revision
limitations, duplicate provider work and the distinction between default exact and optional approximate reads.
