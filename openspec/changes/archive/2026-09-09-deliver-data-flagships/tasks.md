## 1. Legacy adoption flagship

- [x] 1.1 Build the independent modular invoice application and verify persistence, ordinary Rails delivery, public API behavior parity and production loading without Foundry.
- [x] 1.2 Record reviewed upstream debt and verify new-reference rejection, byte-identical baselines and incremental extraction in a disposable copy.
- [x] 1.3 Initialize application-local OpenSpec, document the extraction journey and add independent executable CI; verify workflow artifacts and locked bundle commands.
- [x] 1.4 Add the delivered-example catalog and verify profile/name/configuration links without duplicating architectural settings.

## 2. Data recipes and retrieval

- [x] 2.1 Implement application-owned PostgreSQL outbox publication and verify atomic writes, nested failure, duplicate delivery, crash recovery and poison handling.
- [x] 2.2 Implement pgvector ingestion and embedding lifecycle and verify tenant filtering, versions, deletion and unavailable providers against PostgreSQL/pgvector.
- [x] 2.3 Deliver the RAG flagship with Spec Kit artifacts, citations and retrieval evaluations; verify its independent bundle and CI without model-provider traffic.

## 3. Search and voice

- [x] 3.1 Implement OpenSearch projection backfill, catch-up, validation, cutover and recovery; verify real service failure and duplicate-delivery scenarios.
- [x] 3.2 Deliver the OpenSearch CQRS flagship with Spec Kit artifacts and independent executable CI.
- [x] 3.3 Implement reliable RabbitMQ voice control, separate media handling, authorization, interruption and reconnect; verify bounded buffering, duplicates and poison messages.
- [x] 3.4 Deliver the realtime voice flagship with Spec Kit artifacts and independent executable CI.

## 4. Milestone completion

- [x] 4.1 Reconcile recipes, supported dependency combinations, catalog and current specs after all four apps pass; run core compatibility, RuboCop and specification checks before marking 0.3 complete.

Verified first slice on 2026-09-09: core 96 tests / 709 assertions; adoption app and disposable extracted copy each 3 tests / 18 assertions; real Packwerk accepted/new-debt/extraction checks; production loading without Foundry execution code; independent OpenSpec validation; catalog validation and root/app RuboCop. Ruby 3.4.10, Rails 8.1.3.1, SQLite 2.9.6, packs-rails 0.1.0, Packwerk 3.1.0 and OpenSpec 1.12.0 were exercised locally. Linux dependencies are locked and CI is configured, but remote CI was not run.

Completed remaining scope on 2026-09-09: RAG 6 tests / 38 assertions; OpenSearch/outbox 8 / 43;
RabbitMQ voice 8 / 81; adoption original/extracted copies 3 / 18 each. All app setup, source,
Packwerk, selected workflow prerequisites/validation and production loading checks passed.
Real disposable PostgreSQL 17.11 / pgvector 0.8.6, OpenSearch 2.19.3 and RabbitMQ 4.1.8 were exercised.
Core Ruby 3.4/Rails 8.1 and Ruby 3.3/Rails 7.1 each passed 96 / 709; built 0.3.0 gem 4 / 139;
offline AI 6 / 34; root RuboCop 225 files; six development/eight product skills; four-app catalog;
strict current specs and all Compose definitions passed. Packaged acceptance requires the
verified Bundler 2.6.9 lane; an initial cached Bundler 4 run failed frozen checksums. See
application reconciliation records and docs/compatibility.md. No remote CI, paid provider calls,
production benchmark, manual listening verification or publishing is claimed.
