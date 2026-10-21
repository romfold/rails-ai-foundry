# Skill-led packs and AI acceptance

Local verification on 2026-09-16 used managed Ruby 3.4.10, Bundler 2.6.9 and Node 20.19.0 on macOS arm64. Normal tests made no live model requests. Missing locked gems were installed in a temporary gem home before acceptance. This record distinguishes implementation evidence from hosted CI, publication and production performance.

## Core, packaging and workflows

| Command / lane | Observed evidence |
| --- | --- |
| `bundle exec rake test` | Final 138 tests / 1075 assertions, no failures/errors/skips |
| `BUNDLE_GEMFILE=gemfiles/rails_7_1.gemfile bundle exec rake test` | Final 138 / 1075 on Rails 7.1.6 using managed Ruby 3.4.10, no failures/errors/skips |
| `bundle exec rake test:package` | 6 tests / 370 assertions, built archive installed in disposable gem homes |
| Installed first-feature replay on each Rails lane | 2 / 148 per lane; default and custom roots, independent process persistence, public API, database constraint and private-access failure/repair |
| `BUNDLE_GEMFILE=gemfiles/ai_rails_8_1.gemfile bundle exec rake test:ai` | 8 / 60, provider-blocked native and installed AI acceptance |
| `BUNDLE_GEMFILE=gemfiles/ai_rails_7_1.gemfile bundle exec rake test:ai` | 8 / 60 with the same optional RubyLLM 1.16.0 contract |
| `bundle exec rake test:workflows` | 3 / 39 using real Specify CLI 1.0.0 and OpenSpec 1.12.0 for Codex, Claude and Cursor; Python 3.12.3 isolated in a temporary virtual environment |
| `npm run contracts:validate` | 8 schema assets, 73 actual configuration/report cases; 10 tests / 142 assertions, also passed on Rails 7.1 |
| Native Rake task acceptance after text diagnostics changed | 6 / 28; errors show severity and certainty |
| `bundle exec rubocop` | 493 Ruby files, no offenses |
| `ruby script/validate_skills` | Six upstream development skills and eight product skills |
| `bundle exec ruby script/validate_examples.rb` | Twelve apps and the existing eleven Spec Kit / one OpenSpec workflow split |
| CI YAML parsing | Fifteen workflow files, including the two-job experimental AI matrix |
| Local documentation links | 47 guides and skills; shared references resolved through the installer's source-to-installed layout |

Both Rails lanes above use managed Ruby 3.4.10. This program does not claim a new local Ruby 3.3, Ruby 4 or Linux run. The existing compatibility matrix retains those release lanes and the Ruby >= 3.3 / railties >= 7.1 floors. A configured hosted job is not passing hosted evidence.

The installed tutorial executes the distributed Markdown snippets and then independently asserts persisted behavior. It found and corrected a missing `bin/packwerk` prerequisite and private-model access in the tutorial fixtures. Upstream packs can print debt-regeneration suggestions; the tutorial and skills explicitly keep those outside ordinary verification.

AI acceptance covers custom/nested/acronym namespaces, new-construction prompt edits, missing-file failure, authorization, source-relative production execution and preservation of complete customized receipts. Prompt checks validate declarations and safe file existence only. Contract acceptance exercises successful warnings, failing errors, opt-in scope and combined prompt/source results. Ripper diagnostics remain limited syntax evidence.

## Complete independent corpus replay

Every application ran `bin/setup`, `bin/verify` and its own `bundle exec rubocop` with its own frozen lock. Verification includes behavioral tests, upstream Packwerk, applicable workflow prerequisites and production eager loading. Only the RAG lock changed, adding Neighbor 1.2.0; accepted adoption debt stayed unchanged.

| Application | Result and additional evidence |
| --- | --- |
| rails-native-ai-chat-rubyllm-hotwire | Passed; pack-local prompts, 5 tests / 38 assertions |
| rails-native-agent-tools-structured-output-rubyllm | Passed; prompt contracts, authorization and structured output, 6 / 29 |
| rails-native-rag-pgvector | Passed; 12 / 93, shared SQL/Neighbor lifecycle, stale revision rejection and provider transaction boundaries |
| modular-multi-tenant-rag-qdrant | Passed; real vector lifecycle and tenant isolation |
| modular-opensearch-cqrs | Passed after the explicit local storage adjustment below; 8 / 43, rebuild and outbox recovery |
| modular-realtime-voice-rabbitmq | Passed; real broker and bounded control/media behavior |
| modular-event-pipeline-kafka-karafka | Passed; real Kafka/Karafka transient retry, ordered schemas, duplicate delivery and consumer restart; NATS acceptance |
| modular-transactional-outbox-postgresql-sidekiq | Passed; real Redis and Sidekiq worker, lost-job recovery and deduplication |
| domain-event-sourced-ledger-rails-event-store | Passed; stream replay and expected-version conflicts |
| modular-graphql-async-dataloader | Passed; real Falcon HTTP, batching, tenant and database-role context |
| rails-native-nextjs-graphql | Passed; frozen npm install, production build and actual Rails/Next.js HTTP including unauthorized/unavailable backend paths |
| modular-legacy-adoption-packwerk | Passed; original and extracted-copy behavior, new debt rejected, accepted baseline bytes unchanged |

The apps shared one disposable PostgreSQL 17 pgvector instance on loopback port 55432 with separate application databases. Other services came from their checked-in Compose definitions, each under a distinct `foundry-next-*` project. Pre-existing user PostgreSQL containers on ports 5432/5433 were not used. This local topology verifies integration behavior, not multi-host isolation or production sizing.

OpenSearch initially returned three create-index errors because Docker's 109.4 GB filesystem had approximately 2 GB free (98% used), triggering its percentage watermarks. The disposable cluster alone received transient free-space thresholds: low 1 GB, high 768 MB, flood stage 512 MB; its create-index block was cleared. The rerun passed without changing application code or weakening the tests. No global Docker setting, user data cleanup or production configuration was changed. CI uses the original Compose defaults; adequate disk space is an environmental prerequisite.

The RAG ANN comparison emits all conditions: 240 synthetic vectors, 1536 dimensions, seed 41, five queries, k=5, observed recall 1.0. EXPLAIN verifies the actual HNSW query under test-local forced index order, ef_search 64, strict iterative scanning, 1000 scan tuples and a two-second statement timeout. An initial B-tree/sort plan correctly failed the ANN assertion. These are bounded correctness/evaluation-harness results, not semantic quality, production recall or throughput measurements.

## Independent experimental recipes

| Recipe / command | Evidence |
| --- | --- |
| `recipes/flow-nodes-branching/bin/verify` from its bundle | FlowNodes 0.1.0, 6 tests / 29 assertions; branches, bounded retries, interruption, lost acknowledgment, repeated effects and conflicting keys; five Ruby files pass style |
| `recipes/langchainrb-adoption/bin/verify` from its bundle | Langchainrb 0.19.5, 7 / 34; real native assistant/adapter lifecycle with scripted provider I/O, history isolation, explicit tool dispatch, authorization and request budgets; seven Ruby files pass style |

Both recipes block socket connections and omit Foundry/RubyLLM runtime dependencies. Their Linux platforms are resolved in independent locks; local execution was macOS only. FlowNodes' effect store is in-process and not crash durable. Langchainrb's tool is read-only; the example does not establish exactly-once write effects. Its Ruby 4 logger notice is recorded in its README. Neither recipe changes the catalog, application defaults or support floors.

Initial integration work also corrected a scripted response's Ruby keyword/positional-hash mismatch, explicit archive JSON loading, packaged skill-reference inventory and style offenses. All corresponding acceptance was rerun successfully. Existing upstream parser, locale and deprecation notices remain visible and non-failing.

## Reconciliation and limits

All eight delta operations were compared with the reconciled baselines; unrelated requirements and existing agent scenarios were preserved. Strict validation passed all 28 items before archive and all 27 afterward (26 specifications and the unrelated active release-candidate change). All 17 implementation tasks are complete. Focused implementation commits are `c093c31` (core/skills/checks), `00d2f72` (AI examples/RAG) and `65828cd` (experimental recipes); the final documentation commit records this archive and evidence. Guide links resolve after archive, and all six temporary Compose projects were removed. The unrelated hosted release-candidate gate remains open.

Hosted CI, publication, live evaluations, agent/onboarding studies and a combined ROM + RES + search + RubyLLM + pgvector application remain separate scopes. No success in those areas is inferred from this program's tests.
