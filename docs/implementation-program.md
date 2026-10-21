# Approved conventions implementation program

This ledger records the completed conventions reset. The subsequent [skill-led program](next-program.md) records newer user decisions, implementation and evidence. This is a delivery ledger; use the dated compatibility evidence for executed checks. The completed conventions reset is recorded in `openspec/changes/archive/2026-09-09-reset-foundry-conventions/`. Historical ADRs and OpenSpec archives remain historical records. Publishing is separate.

## Product contract

Foundry becomes a development-time kit of architecture conventions, generators, checks, skills, and executable examples. Applications execute ordinary Rails and upstream library code. The breaking cutover removes Foundry-owned loading, composition, transaction, event, aggregate, projection, and AI execution runtimes. No compatibility runtime or automatic business-data conversion ships with the final reset.

Profiles (`rails_native`, `modular`, `domain`), event patterns, CQRS patterns, capabilities, application workload, and specification workflow are independent. Configuration changes require a visible proposal or preview. Efficient persistence reads are allowed in every profile; introduce ports for actual business or integration boundaries, not mandatory wrappers around Active Record.

| Artifact | Responsibility |
| --- | --- |
| `package.yml` | Topology, dependencies, privacy, public paths, stewardship |
| Pack-local `foundry.yml` | Profile, namespace, patterns, capabilities |
| Root `config/foundry.yml` | Defaults, workload, workflow; checker/adoption mappings are reserved and empty in schema 1 |
| Root `config/ai.yml` | Application-owned model aliases |
| Workflow requirements | Behavior and acceptance criteria |
| Workflow plans and ADRs | Proposed implementation and rationale |
| Code, tests, checks, evaluations | Implementation and evidence |

Workflow artifacts reference installed architecture configuration. Constitutions contain general principles rather than duplicate inventories. Foundry delegates discovery to `packs-specification`, package operations to `packs`, Rails loading to `packs-rails`, and topology/privacy/cycles to Packwerk and its extensions. New applications use `packs/`; adoption preserves roots. Feature delivery stays in its pack; Rails base classes and shared delivery remain in the shell; migrations remain at root.

## Specification policy

New applications without a workflow default to Spec Kit; existing applications without one default to OpenSpec. Preserve established selections. The Foundry repository keeps OpenSpec. Explicit `none` is supported. This is Foundry product policy, not an upstream limitation: both tools support new and existing applications.

Keep setup-only integrations small and versioned. Do not introduce a `SpecificationProvider` runtime, fork templates, convert history, or synchronize two tools. Preflight prerequisites, collision behavior, interruption, and application-root isolation. Python/uv requirements belong only to selected Spec Kit tooling. Reconcile living specifications after requirements changes; use each workflow's own validation or reconciliation and independent tests.

## Milestones and current status

| Release | Required delivery | Status |
| --- | --- | --- |
| 0.2 | Core runtime reset, independent settings, upstream packages, native generators, workflow selection, checks, native AI conventions | Implemented and locally verified; publishing separate |
| 0.3 | Outbox, pgvector, search, RabbitMQ, four priority flagship applications | Implemented and locally verified; all four flagships and data recipes delivered |
| 0.4 | All twelve standalone apps; RES, Qdrant, Kafka, NATS, GraphQL, Falcon, Next.js | Complete; twelve apps locally verified (see compatibility.md) |
| 0.5 | ROM composition, optional DI/workflow recipes, experimental vectors, complete adoption/parity tooling, evaluations and benchmarks | Complete; recipes, audit/parity and evidence tooling locally verified |
| 1.0 | Stable schemas, generators, skills, diagnostics, compatibility and upgrade policy | Complete; stable contracts and upgrade policy locally verified; publishing separate |

Support tiers distinguish core Rails/packs/native operations and optional RubyLLM, mainstream data/messaging recipes, advanced ROM/Qdrant/async/frontend combinations, and experimental Pinecone/Weaviate. Record concrete verified combinations and block known incompatible combinations; configuration acceptance alone does not confer support.

The 0.2 cutover removes all Foundry application execution runtimes and legacy generators. Native onboarding, context/component/delivery generation, optional direct RubyLLM agents, independent settings, workflow selection, boot-free source checks and explicit upstream Packwerk verification are implemented. The [compatibility record](compatibility.md) documents passing native core, built-gem, AI and workflow acceptance.

Advanced recipes, opt-in live evaluation tooling and comprehensive debt/parity auditing are delivered in 0.5; actual live provider and agent/onboarding measurements require their own explicitly configured runs. Fully resolved Packwerk baselines need separate review because of an upstream stale-detection limitation. Source diagnostics are migration evidence with declared limitations, not proof of dynamic Ruby behavior.

## Twelve-application corpus

The twelve-app corpus is implemented with independent locked bundles, application-local workflows,
executable CI and local acceptance evidence. Eleven greenfield applications use Spec Kit 1.0.0;
legacy adoption preserves OpenSpec 1.12.0. The catalog reads architecture from focal configuration.
Alternate workflow selections and none remain covered by generated-consumer fixtures.

| Directory under `examples/` | Focal demonstration | Delivery |
| --- | --- | --- |
| [rails-native-ai-chat-rubyllm-hotwire](../examples/rails-native-ai-chat-rubyllm-hotwire/README.md "Repository-only reference; not installed") | Persistent and streaming chat, Rails delivery | **0.4; locally verified** |
| [rails-native-agent-tools-structured-output-rubyllm](../examples/rails-native-agent-tools-structured-output-rubyllm/README.md "Repository-only reference; not installed") | Authorized tools, schemas, evaluations | **0.4; locally verified** |
| [`rails-native-rag-pgvector`](../examples/rails-native-rag-pgvector/README.md "Repository-only reference; not installed") | Ingestion, tenant retrieval, citations | **0.3 flagship; locally verified** |
| [modular-multi-tenant-rag-qdrant](../examples/modular-multi-tenant-rag-qdrant/README.md "Repository-only reference; not installed") | External vector boundary and tenant isolation | **0.4; locally verified** |
| [`modular-opensearch-cqrs`](../examples/modular-opensearch-cqrs/README.md "Repository-only reference; not installed") | Derived search model and reindexing | **0.3 flagship; locally verified** |
| [`modular-realtime-voice-rabbitmq`](../examples/modular-realtime-voice-rabbitmq/README.md "Repository-only reference; not installed") | Voice control, interruption, reliable messaging | **0.3 flagship; locally verified** |
| [modular-event-pipeline-kafka-karafka](../examples/modular-event-pipeline-kafka-karafka/README.md "Repository-only reference; not installed") | Consumers, ordering, retries, schema evolution | **0.4; locally verified** |
| [modular-transactional-outbox-postgresql-sidekiq](../examples/modular-transactional-outbox-postgresql-sidekiq/README.md "Repository-only reference; not installed") | Atomic publication intent and crash recovery | **0.4; locally verified** |
| [domain-event-sourced-ledger-rails-event-store](../examples/domain-event-sourced-ledger-rails-event-store/README.md "Repository-only reference; not installed") | Authoritative streams, optimistic concurrency | **0.4; locally verified** |
| [modular-graphql-async-dataloader](../examples/modular-graphql-async-dataloader/README.md "Repository-only reference; not installed") | Batched concurrent reads and Fiber context | **0.4; locally verified** |
| [rails-native-nextjs-graphql](../examples/rails-native-nextjs-graphql/README.md "Repository-only reference; not installed") | Rails-root monorepo, separate frontend | **0.4; locally verified** |
| [`modular-legacy-adoption-packwerk`](../examples/modular-legacy-adoption-packwerk/README.md "Repository-only reference; not installed") | Incremental extraction and no-new-debt checking | **0.3 flagship; locally verified** |

Names begin with the focal context profile, then meaningful behavior and distinguishing dependencies in readable kebab-case. YAML uses `rails_native`, directory names use `rails-native`. Do not encode workflow names, dependency versions, or every Gemfile entry. Prefixes describe the focal context rather than every pack. Each completed example README identifies that context and links to its installed configuration. The eventual catalog records only location and focal context; derive architecture details from configuration and verify all links before publishing it.

## Correctness gates

- Default applications use PostgreSQL, Puma, Hotwire, Solid Queue, and no additional cache. Offer Sidekiq, caching, replicas, async servers, and frontend alternatives explicitly. Keep ordinary writes synchronous; durable asynchronous work needs persisted intent, status, and failure handling. Do not assume a traffic ratio, require sharding on day one, or make unmeasured performance claims.
- Persist business state and outbox intent in the same transaction. With ROM, both use the same ROM gateway transaction; deliver to RES or other destinations afterward. Sharing a database with Active Record does not establish atomicity across gateways.
- Verify failed results, nested rollback, publication/acknowledgment crash windows, duplicate delivery, optimistic conflicts, ordering and poison messages. Avoid exactly-once claims.
- Treat search and external vector indexes as rebuildable projections. Cover backfill, catch-up, validation, cutover and recovery. RAG also covers tenant filtering, embedding versions, deletion, retrieval quality, citations and unavailable providers.
- Use direct RubyLLM conventions, feature-owned prompt files, root model aliases, prompt contracts, evaluations and application-authorized tools. The subsequent [skill-led program](next-program.md) places new prompts inside the pack. Prompt text is not authorization enforcement.
- Separate voice control and media responsibilities. Verify interruption, bounded buffering, reconnect behavior and authorization. Async recipes verify Fiber-local tenant context, database roles and connection cleanup.
- Normal tests remain offline. Live evaluations require explicit activation, credentials, model selection and request/token/time/spend limits. Record actual provider usage where available and do not present estimated limits as a guaranteed bill cap.
- Structural checks never boot Rails or execute package code. Full Packwerk checks may boot in an isolated environment. Foundry diagnostics declare detected, warning or review certainty and acknowledge dynamic Ruby limits.
- Keep Packwerk authoritative. Enable pks only after application-specific parity evidence. Compare violation identities against preserved upstream baselines, reject new debt, and never regenerate accepted debt during a normal check. Run parity regeneration in a disposable copy.
- Verify built-gem installation, ordinary Rails loading, routes/views/jobs, prompt lookup, repeats, collisions and interrupted setup. Test workflow defaults, overrides, preservation, ambiguity, missing prerequisites, none and root isolation. Preserve Ruby >= 3.3 and railties >= 7.1 core floors; isolate optional integrations in their own lanes.
- Retain Foundry's OpenSpec CI and give each example workflow-appropriate evidence. Benchmark vanilla Rails and Foundry with matching agent/model/workflow conditions; report complete onboarding comparisons separately. Use repeated measurements and held-out behavioral tests.
- Rewrite current APIs, README, AGENTS, skills, architecture documentation and roadmap during verified cutover. Remove obsolete runtimes, fixtures and the two old examples during the authorized 0.2 cutover, verified through native generated consumers. Update baseline specifications only after verified implementation; preserve ADRs and archived changes as history.

Complete bounded changes with appropriate tests, RuboCop, specification checks and focused Conventional Commits. A completed planning artifact is not an implementation release.

## 0.3 adoption delivery evidence — 2026-09-09

The first flagship verifies paid/unpaid invoice totals, repeated local payment transitions, model/database constraints, pack-owned HTTP delivery, accepted upstream debt, rejection of a new source identity and endpoint extraction in a disposable copy. Normal verification preserves checked-in debt. Rails production eager loading requires no Foundry execution code; path-gem version metadata can still be evaluated by Bundler.

The app owns Ruby and Node locks, uses OpenSpec 1.12.0 initialized upstream, and has an independent CI job. Local verification passed; remote CI is not claimed run. The example uses SQLite intentionally for the extraction exercise. The remaining data and messaging acceptance is now complete, as recorded below.

## 0.3 completed data delivery — 2026-09-09

The PostgreSQL/pgvector, OpenSearch and RabbitMQ flagships are independently executable and
have passed real local integration acceptance. Each has upstream-initialized Spec Kit 1.0.0,
a living contract and reconciliation evidence. The catalog validates all four focal profiles
and README configuration links. The [data recipes](data-recipes.md) link directly to application
code and correctness tests; no execution runtime was added to the gem.

- RAG: 6 tests / 38 assertions; tenant/version filtering, atomic ingestion, reembedding,
  deletion, cited answers, provider failures and deterministic retrieval evaluation.
- Search/outbox: 8 tests / 43 assertions; committed crash windows, nested failed results,
  concurrent dispatch, poison/replay, real write failures, catch-up, validation and cutover.
- Voice: 8 tests / 81 assertions; broker confirms, mandatory routing, duplicate identities,
  dead letters, reconnect, interruption, concurrent media bounds and Rails view/API delivery.
- Adoption: 3 tests / 18 assertions in both original and disposable extracted applications;
  accepted debt preserved, new debt rejected, behavior unchanged.

All four pass Packwerk and production eager loading without Foundry execution code. The core
passes Ruby 3.4/Rails 8.1 and Ruby 3.3/Rails 7.1 (96 tests / 709 assertions each). Built 0.3.0 gem
acceptance passes 4 tests / 139 assertions; offline AI passes 6 tests / 34 assertions.
See [compatibility](compatibility.md) for exact versions, tooling constraints and limitations.
The completed change is archived under `openspec/changes/archive/2026-09-09-deliver-data-flagships/`.
Remote CI, provider-quality evaluations, manual listening checks and publishing are not claimed.

## 1.0 stable contracts completed — 2026-09-10

The [stable contracts and upgrade policy](stable-contracts.md) defines the public 1.x surface,
configuration schema 1, versioned reports, generator/skill ownership and support tiers. The built
1.0.0 gem includes eight JSON Schema assets and boot-free contract/version discovery. Unsupported
root/workflow settings now fail before setup or context-based generation. Native 0.5 configuration
without an explicit schema remains accepted, and customized scaffolds/skills are never auto-migrated.

Final core acceptance passes 111 tests / 862 assertions on both Ruby 3.3/Rails 7.1 and Ruby 3.4/Rails 8.1;
built-gem consumers pass 4 / 220, both offline AI Rails lanes pass 6 / 58, and pinned workflow setup
passes 3 / 39. The schema lane validates 67 cases. Real parity/debt acceptance, all twelve frozen
example bundles, skills, catalog and style pass. See [compatibility](compatibility.md) for exact evidence,
corrections and unexecuted lanes. Optional recipes retain their existing tiers and dated service evidence.

Implementation is committed as c2661c0. The verified change is archived under
`openspec/changes/archive/2026-09-10-stabilize-foundry-contracts/`; current specifications describe the
accepted contracts. Publication, hosted CI and live provider measurements remain separate.
