## 1. Independent application

- [x] 1.1 Install the independent Rails/ROM/RES/Elasticsearch/RubyLLM bundle and initialize pinned Spec Kit; verify locks, workflow prerequisites and ordinary Rails loading.
- [x] 1.2 Implement Access and Knowledge lifecycle/persistence; verify tenant isolation, revisions and failed/nested transaction rollback against PostgreSQL.

## 2. Durable composition

- [x] 2.1 Implement fenced delivery leases and post-commit RES publication; verify crashes, duplicates, conflicts, concurrent workers, expired leases and poison recovery.
- [x] 2.2 Implement Elasticsearch and ROM/pgvector projections; verify current visibility, stale/reordered work, deletion and provider failure.
- [x] 2.3 Implement search/vector rebuilds; verify concurrent mutation, failed validation, atomic cutover and restart recovery.

## 3. Delivery and acceptance

- [x] 3.1 Implement authorized RubyLLM answering and Rails UI/status; verify HTTP behavior, tools, prompt lookup, citations and instrumentation offline.
- [x] 3.2 Add independent CI and operational documentation; run real service acceptance, Packwerk, RuboCop, workflow and production loading checks and record exact evidence.
