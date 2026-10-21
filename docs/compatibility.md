# Compatibility and verification

Foundry 1.0 keeps Ruby >= 3.3 and railties >= 7.1. The managed development pair is Ruby 3.4.10 / Rails 8.1.3.1 with Bundler 2.6.9 and Node 20.19.0. Optional RubyLLM 1.16.0 uses separate bundles; it is not a core dependency. Application execution uses packs-rails 0.1.0, packs 0.3.0, packs-specification 0.0.11 and Dry::Operation 1.1.x. Explicit boundary acceptance uses Packwerk 3.1.0 and packwerk-extensions 0.3.0.

## Cutover evidence — 2026-09-09

| Executed local lane | Result |
| --- | --- |
| Ruby 3.4.10 / Rails 8.1.3.1 core | 94 tests, 703 assertions, passed |
| Ruby 3.3.10 / Rails 7.1.6 core, Bundler 2.5.18 | 94 tests, 703 assertions, passed |
| Ruby 3.4.10 / Rails 7.1.6 core before final added regression | 93 tests, 699 assertions, passed |
| Ruby 3.4.10 / Rails 8.1.3.1 built-gem consumers | 4 tests, 139 assertions, passed |
| Ruby 3.4.10 / Rails 8.1.3.1 offline AI | 6 tests, 28 assertions, passed |
| Ruby 3.4.10 / Rails 7.1.6 offline AI | 6 tests, 28 assertions, passed |
| Real Specify CLI 1.0.0 / OpenSpec 1.12.0 consumer setup | 3 tests, 39 assertions, passed |

Core acceptance covers configuration safety, discovery, native generator placement, repeats/collisions, delivery, direct results and nested rollback, root isolation, boot-free checks, source migration evidence and removed CLI behavior. Built-gem acceptance verifies installation provenance, upstream loading, skills, generated application dependencies, SQLite queue persistence, PostgreSQL recipe generation, production exclusion of Foundry and real Packwerk debt behavior. AI tests cover provider-stubbed tool exchanges, authorization denial, plain prompt lookup, structured-output configuration and provider failure. These do not establish model quality or application-specific tenant isolation.

The reduced test count reflects removal of tests for retired 0.1 runtimes and examples. Native behavior tests remain. No live model requests, publication or remote CI execution are claimed. Ruby 4.0 and intermediate Rails lanes remain configured separately; a configured CI job is not local passing evidence.

## Reproduce

Use managed Ruby explicitly as shown in README, then install dependencies before offline acceptance:

```sh
bundle exec rake test test:package
BUNDLE_GEMFILE=gemfiles/rails_7_1.gemfile bundle exec rake test
BUNDLE_GEMFILE=gemfiles/ai_rails_8_1.gemfile bundle exec rake test:ai
BUNDLE_GEMFILE=gemfiles/ai_rails_7_1.gemfile bundle exec rake test:ai
bundle exec rake test:workflows
bundle exec rubocop
ruby script/validate_skills
npm run spec:validate
```

`script/prepare_acceptance` provisions generated-consumer dependencies. Real workflow acceptance requires pinned upstream tools on PATH. `FOUNDRY_ACCEPTANCE_WORKFLOW=spec-kit|openspec` selects the real workflow in packaged creation acceptance. Ordinary tests remain offline; the real workflow lane may use upstream tooling network access but never model providers.

The new-application recipe constrains JSON to >= 2.9 and < 3 because Rails 8.1.3.1 job persistence passes positional parser options. AI bundles also constrain JSON below 3 for Faraday 2.14. These recipe constraints do not impose a new core compatibility floor. Preserve known constraints when changing dependency combinations.

Packwerk remains authoritative. Foundry checks preserve accepted debt and fail on new violations, but Packwerk 3.1.0 can miss fully resolved stale baselines. Review cleanup separately; 0.5 adds disposable debt auditing and application-specific parity evidence; see the advanced evidence below. Source diagnostics report syntax evidence and do not prove dynamic constant resolution.

Initial cutover checks found formatting issues, which were corrected. Ruby 3.3 initially lacked upstream packs dependencies in its default gem path; the successful run used the already installed local upstream gems. Existing RDoc duplicate-constant and upstream Rails/RubyLLM deprecation warnings did not fail acceptance. Historical implementation evidence remains in Git and OpenSpec archives; current claims use the native cutover lanes above.

Final RuboCop validation passed all 110 Ruby files; six development and eight product skills validated. All 120 delta operations were compared against the reconciled current specifications. Git whitespace validation was corrected before commit.

## 0.3 data and flagship evidence — 2026-09-09

| Independent application | Tested combination | Passing local evidence |
| --- | --- | --- |
| pgvector RAG | Ruby 3.4.10, Rails 8.1.3.1, pg 1.6.3, PostgreSQL 17.11, pgvector 0.8.6, RubyLLM 1.16.0, ruby_llm-schema 0.4.0 | 6 tests / 38 assertions; setup, Packwerk, Spec Kit prerequisites, production boot and RuboCop |
| OpenSearch CQRS/outbox | Same Ruby/Rails/PostgreSQL, OpenSearch 2.19.3, opensearch-ruby 3.4.0 | 8 tests / 43 assertions; real write failures, concurrent dispatch, backfill/catch-up/cutover, setup/CLI and all app checks |
| RabbitMQ voice | Same Ruby/Rails/PostgreSQL, RabbitMQ 4.1.8, Bunny 2.24.0 | 8 tests / 81 assertions; confirms/routing, crash/reconnect, poison, bounded concurrent media, setup/worker/HTTP view and all app checks |
| Legacy adoption | Ruby 3.4.10, Rails 8.1.3.1, SQLite 2.9.6, Packwerk 3.1.0 | 3 tests / 18 assertions in original and extracted copy; new debt rejected and accepted baseline unchanged |

All four use packs-rails 0.1.0 and Puma 7.2.1. Each has its own locked macOS/Linux bundle.
The three greenfield apps were initialized with upstream Specify 1.0.0; the adoption app keeps
OpenSpec 1.12.0. Example Compose files pin the tested pgvector image digest; OpenSearch and
RabbitMQ pin tested release tags. Services are loopback-only acceptance infrastructure.

All database examples constrain JSON to >= 2.9 and < 3: Rails 8.1 positional JSON parser options
are incompatible with JSON 3.0 in these exercised paths. The locked bundles enforce the constraint.
RAG uses SQL schema format because the plain Active Record schema dumper cannot preserve its
custom vector column; the CI lane installs PostgreSQL client 17 from the official PGDG repository.
The string vector adapter can emit an unknown-OID warning without affecting validated vector SQL.
OpenSearch's client emits upstream MultiJson deprecation warnings. These do not fail tests.

The 0.3 completion run also passes both core floors (96 tests / 709 assertions each), built-gem
acceptance (4 / 139), offline AI on Rails 8.1 (6 / 34), 225-file root RuboCop, all product/development
skill checks, the four-example catalog, and strict OpenSpec validation. A first packaged run
selected cached Bundler 4 and failed frozen checksums; rerunning with `BUNDLE_VERSION=2.6.9`
passed the declared lane. Bundler 4 compatibility is not established by this release.

No hosted CI run, live model/speech requests, model-quality claims, production throughput
benchmark or browser listening test is claimed. Read each recipe's limits: the final search
catch-up pass pauses writes, RAG uses a tiny deterministic offline corpus, and the voice demo
uses HTTP PCM rather than WebRTC. The remaining eight applications were delivered in 0.4; see the evidence below.

## 0.4 complete corpus evidence — 2026-09-09

All eight new apps use Ruby 3.4.10, Rails 8.1.3.1, pg 1.6.3, PostgreSQL 17.11 and their own locked bundles.
Each passed structural checks, Packwerk, Spec Kit prerequisites, production eager loading without Foundry execution and RuboCop.

| Application | Pinned integration | Behavioral evidence |
| --- | --- | --- |
| Chat | RubyLLM 1.16.0, turbo-rails 2.0.23 | 5 tests / 38 assertions; persistence, ownership, escaped streaming, provider failure |
| Authorized tools | RubyLLM 1.16.0, ruby_llm-schema 0.4.0 | 6 / 29; per-call permission, revocation, structured response evaluations |
| Qdrant RAG | Qdrant 1.15.4 | 4 / 24; tenant/version/deletion, citations, backfill/catch-up/validation/cutover/recovery |
| Sidekiq outbox | Sidekiq 7.3.9, connection_pool 2.5.5, Redis 7 | 5 / 30 plus actual worker; rollback, crash/loss/duplicates, poison repair |
| RES ledger | Rails Event Store 3.1.0 | 5 / 21; replay, invalid debits, concurrent expected-version conflict, rollback |
| Kafka/NATS pipeline | Kafka 3.9.1, Karafka 2.4.13, NATS 2.11.8, nats-pure 2.5.0 | 5 / 27 plus actual Kafka consumer retry/restart; ordered schemas, durable JetStream replay/ack/poison |
| Async GraphQL | GraphQL 2.5.14, Falcon 0.51.1, traces 0.18.2 | 5 / 24 plus actual Falcon HTTP; batching, multiplex isolation, concurrent PostgreSQL, role/connection cleanup |
| Next.js/GraphQL | GraphQL 2.5.14, Next.js 16.3.4, React 19.3.0, Node 20.19.0 | 2 / 5 plus production frontend build and real Rails/Next.js HTTP acceptance |

Known incompatibilities are blocked by the owning bundles: Sidekiq 7.3.9 fails its scheduler with
connection_pool 3.x, so its example pins 2.5.5. Falcon 0.51.1 requires explicit traces 0.18.2 with the
resolved async stack; without it the CLI fails to load traces/provider. The existing JSON < 3 constraints
remain. These optional integration locks do not raise the core Ruby/Rails floor.

The GraphQL example's reading role uses the same local database; tests prove role propagation and write prevention,
not physical replica behavior. Its scoped connections prevent persistent checkout by nested code. Qdrant uses a
small deterministic embedding corpus and pauses writes during final validation; no ANN quality/scale claim is made.
Chat's default provider is an offline demonstration and a killed process can leave a pending turn requiring recovery.
The Sidekiq intent is retried until database acknowledgment, independent of Redis job loss. Kafka/NATS require
trusted producer ACLs; poison repair and sequence-gap handling remain visible operator responsibilities.
Next.js is a separate server/bundle with a no-store proxy; demo identities are not a production authentication system.

Eleven examples were initialized with upstream Specify CLI 1.0.0, and adoption keeps OpenSpec 1.12.0.
Workflow artifact checks do not establish behavior. All stated broker/vector/database evidence used real local
services; model adapters remained offline. No hosted CI, live provider, production throughput or deployment is claimed.

The final 0.4 run verified all twelve applications against the 0.4.0 gem, including setup, behavioral
suites, production loading, boundary checks and application RuboCop. Both core lanes passed
96 tests / 709 assertions each (Ruby 3.4/Rails 8.1 and Ruby 3.3/Rails 7.1); built-gem acceptance
passed 4 / 139 and optional offline AI passed 6 / 34. All example locks use Bundler 2.6.9 and
frozen local installation was checked separately. The packaging harness now explicitly preserves
the invoking Bundler version across its unbundled child processes.

Kafka Compose uses separate host and internal listeners so container health checks do not follow
a host-only advertised port; the actual Compose health check and host consumer retry/restart passed.
Independent CI definitions are supplied, but hosted CI execution is not claimed.

Final style validation passed 428 Ruby files. The six development skills, eight product skills,
twelve-entry catalog, workflow split (eleven Spec Kit, one OpenSpec), all workflow YAML and
all example Compose configurations validated. Linux lock resolution preserved every tested
macOS dependency version; Linux execution remains delegated to the supplied CI lanes.

## 0.5 advanced composition and evidence — 2026-09-10

| Capability | Verified combination | Passing local evidence |
| --- | --- | --- |
| ROM and optional composition | Ruby 3.4.10, rom-sql 3.7.0, rom 5.4.3, dry-operation 1.1.0, dry-system 1.2.5, trailblazer-operation 0.11.1, PostgreSQL 17.11 | 7 tests / 30 assertions; nested rollback, independent commit/ack crash window, duplicate recovery, poison repair and native results |
| Experimental vectors | Weaviate 1.36.6; Pinecone 2025-04 vector protocol | 5 offline tests / 33 assertions; real Weaviate 1 / 9 for tenant/version/update/deletion isolation; no live Pinecone call |
| Adoption/parity | Packwerk 3.1.0, pks 0.2.40, Rails 8.1.3.1 | Real matching two violation identities, fresh evidence verification, fully resolved debt detection, new source rejection and preserved source bytes |
| Evaluation guards | RubyLLM 1.16.0, Ruby 3.4.10 | 7 tests / 39 assertions; activation/credentials/budgets, unknown usage, output overrun, timeout/error, scoring and actual adapter retry/output configuration; all provider traffic mocked |
| Runtime benchmark | Active Record 8.1.3.1, SQLite 2.9.6, dry-operation 1.1.0 | 2 tests / 5 assertions, held-out behavioral gate and 9 paired trials with 200 writes each; raw results in recipes/evidence/results/runtime.json |

Final core acceptance passes 102 tests / 739 assertions on both Ruby 3.4/Rails 8.1 and Ruby 3.3/Rails 7.1.
The built-gem suite passed 4 / 139; its expanded installed boundary/audit case then passed 1 / 48,
including four fully resolved identities with the original baseline preserved. Optional offline AI passed 6 / 34.
Root RuboCop passed 460 files; six development skills, eight product skills, twelve catalog entries and
all three independent recipe frozen installations passed. All twelve app locks still resolve against 0.5.0.

The focused installed-gem run exposed an existing boundary-check subprocess selecting cached Bundler 4.
Boundary checks now preserve the invoking Bundler version just like the audit runner; the regression
and installed-gem tests pass with Bundler 2.6.9. Optional recipes pin that Bundler version and include
Linux resolution. Linux recipe CI is supplied; hosted CI execution is not claimed.

The local pks 0.2.40 binary SHA-256 was 256b831ccccdcbe844ef55fadcc3c93de3cdf73ef6b5949530e6a90f63c9e452.
CI builds the verified upstream release source revision 953d016a8cf7aa1a813391f29de969289404c6f5;
parity evidence remains specific to the actual application, inputs, Ruby and binary. The crates.io metadata
endpoint returned HTTP 403 locally, so CI uses the verified Git source revision instead of an unverified registry lookup.

The runtime sample's median batch time was 21.883 ms for vanilla Rails and 21.950 ms for native operations,
with approximately 29,200 versus 29,600 Ruby allocations per 200 writes. This narrow SQLite result does not
establish a production throughput difference, agent productivity, HTTP latency or onboarding improvement.
The offline JSON report is scorer calibration, not model-quality evidence. Live model/Pinecone requests,
agent/onboarding runs and publishing require separate explicitly configured execution and are not claimed here.

## 1.0 stable contracts — 2026-09-10

Final core acceptance passes **111 tests / 862 assertions** on both Ruby 3.4.10 / Rails 8.1.3.1
and Ruby 3.3.10 / Rails 7.1.6. Root RuboCop passes all 462 Ruby files; the final discovery/test
change also passes focused RuboCop.

Version 1.0.0 retains the core dependency floors and the existing optional integration pins.
The [stable contract and upgrade guide](stable-contracts.md) identifies the public surface and
intentional upgrade changes: strict root/workflow keys, reserved empty checker/adoption mappings,
versioned reports and regeneration of old parity evidence. No application execution runtime was added.

Contract acceptance validates eight draft-07 schema assets against 67 configuration/report cases,
including all checked-in example configuration, actual CLI source/refactor failures, boundary failure
reporting and Ruby validation decisions. Boundary/audit backend responses in this schema lane are
controlled fixtures; real upstream behavior is verified separately by packaged and parity acceptance.
The expanded focused suite passes 8 tests / 119 assertions, including no-write rejection of invalid root
configuration by setup, component and agent generation. The standalone inventory was also executed
with an explicit assertion that Rails had not loaded.

The built 1.0.0 gem passes 4 tests / 220 assertions: isolated installation and schema provenance,
workflow-neutral skill installation, native component generation, ordinary Rails loading/execution,
new-app dependencies and queue persistence, plus real Packwerk debt preservation and disposable audit.
Both optional AI lanes (Ruby 3.4.10 with Rails 8.1.3.1 and Rails 7.1.6) pass 6 / 58 each, including
installed-gem prompt/tool behavior with provider traffic blocked. Real Specify 1.0.0/OpenSpec 1.12.0
workflow acceptance passes 3 / 39 across all three agent integrations.

Real Packwerk 3.1.0/pks 0.2.40 acceptance passes matching two retained identities, fresh versioned evidence
verification, two fully resolved identities, two rejected new source identities and byte preservation.
The pks binary identity is unchanged from the 0.5 evidence. All twelve example bundles pass frozen
local dependency checks against 1.0.0; their application/service behavior is unchanged and retains the
dated 0.3–0.5 evidence above. Eight product skills pass both repository and skill-creator validation;
six upstream development skills and the twelve-app catalog also validate.

Initial checks exposed two fixtures using the newly rejected workflow.note field, an installed-test
executable PATH assumption, strict schema typing/namespace anchors and a test stub arity error.
These were corrected and rerun. Final review also closed root-contract validation bypass in component
and agent discovery. Existing RDoc/Rails/RubyLLM/parser warnings remain non-failing. Contributor Ajv
was moved from the initially attempted 8.17.1 to patched 8.20.0; the completed npm install reported
zero advisories in that root tooling bundle. Ajv is not a gem or application dependency.

Ruby 4/Bundler 4, Linux/hosted CI, live providers, production throughput and publication are not
claimed verified by this milestone. The supplied CI keeps those optional compatibility lanes and
adds contract-schema validation to the managed job. The support tiers remain explicit; 1.0 does not
promote experimental vectors or make universal upstream-version compatibility claims.

All five new requirements and their scenarios were compared exactly after synchronization. Final
strict OpenSpec validation passes 24 baseline specifications with no active changes remaining.
Implementation and acceptance are complete locally; the version is not published.

## Generator and report contract fixes — 2026-09-10

Locale-independent reports, shared component/agent constant ownership and application-owned namespace
inflections are verified by the [fix acceptance record](../openspec/changes/archive/2026-09-10-fix-generator-and-report-contracts/acceptance.md "Repository-only reference; not installed").
Managed and Rails 7.1 core suites pass 125 tests / 983 assertions each; both offline AI lanes pass
7 / 59. Installed-gem acceptance under `LC_ALL=C` passes 4 / 222, and the UTF-8 boundary/audit lane
passes 1 / 72. RuboCop, skills, catalog and stable contracts pass. Workflow acceptance is unavailable
in this run because `specify` is missing; the separate release candidate's hosted CI gate remains open.
The [stable contract guide](stable-contracts.md) documents explicit repair for existing acronym contexts.

## Skill-led packs and AI — 2026-09-16

Both Rails 8.1.3.1 and Rails 7.1.6 core lanes pass **138 tests / 1075 assertions** using managed
Ruby 3.4.10. Installed-gem acceptance passes 6 / 370; the distributable first-feature tutorial
also passes independently on both Rails lanes with default and custom package roots. Each optional
AI lane passes 8 / 60. Real Specify CLI 1.0.0/OpenSpec 1.12.0 initialization passes 3 / 39 across
all three agent integrations. Contract validation covers eight schema assets and 73 actual cases.

All twelve independently locked applications pass setup, behavior, boundary/workflow checks,
production loading and style. The three native AI examples now use explicit pack-local prompts.
The pgvector app adds Neighbor 1.2.0, source-key deduplication and revision-safe reembedding;
12 / 93 includes a bounded actual-HNSW recall comparison and payload-safe notifications.
The OpenSearch replay needed disclosed test-only free-space watermarks on the local Docker disk.

Experimental recipes remain separate: FlowNodes 0.1.0 passes 6 / 29 and Langchainrb 0.19.5 passes
7 / 34, with socket-blocked provider boundaries and their own locks/CI jobs. Neither is a new
core dependency or a production durability/model-quality claim. Root style passes 493 files;
six development skills, eight product skills and the twelve-app catalog validate.

Read the [complete acceptance record](../openspec/changes/archive/2026-09-16-skill-led-packs-and-ai/acceptance.md "Repository-only reference; not installed")
for commands, corrected failures, service conditions and limits. Ruby 3.3/4 and Linux were not
rerun locally by this program; their existing CI lanes remain. Hosted CI, live providers,
combined-stack evidence and publication remain separate.

## Coordinated knowledge program — 2026-09-16

The [integrated recipe](../recipes/domain-knowledge-rag-rom-res-elasticsearch-pgvector/README.md "Repository-only reference; not installed")
now verifies the complete ROM + RES + Elasticsearch + RubyLLM + pgvector composition with
PostgreSQL 17.11, pgvector 0.8.6 and Elasticsearch client/API/server 9.3.0. Its independent
lockfile and acceptance record govern this advanced combination. The [adoption replay](../recipes/knowledge-adoption/README.md "Repository-only reference; not installed")
verifies existing data through AR-preserving extraction, a separate ROM change and later integration.

The contributor benchmark uses Ruby 3.4.10 / Rails 8.1.3.1 / SQLite 2.9.6 on Linux ARM64.
All 36 original grader controls and nine delivery regression controls pass. The eighteen-trial
Cursor CLI 2026.09.15-d2fe57e / Composer 2.5 pilot completed at revision
`fde15a8a36c15fe648f31b5aa56f002d6883232b`; [findings and raw evidence](../benchmarks/evidence/2026-09-16/pilot-cursor-composer-2.5/OUTCOME.md "Repository-only reference; not installed")
separate original outcomes from post-pilot corrected grading. The earlier Codex Astra and
Spark startup failures remain historical evidence. No replacement trials were added to the
Cursor experiment. Hosted CI remains pending; small local tasks do not establish broad
productivity, model quality or untested platform compatibility.

## September 17 bounded knowledge verification

The integrated knowledge recipe retains its independent lock and pinned server/client
combination. See [bounded operations evidence](knowledge-operations-evidence.md) for the
process-recovery, installed-consumer and 1,000/10,000-document local acceptance. The
[runbook](knowledge-operations.md) documents additive migrations, worker upgrade discipline,
alias uncertainty and the global writer gate limitation. Earlier evidence remains historical;
this verification does not rerun or change the September 16 coding-agent pilot.

## September 19 benchmark replacement

The independent contributor bundle pins Le Mans 1.3.5 at
`2d0b7fb8d3b0077574dcf7b70fd4e32c8f9d6e76` with Ruby 3.4.10. The complete AI-evals
corpus is pinned at `5327efe54dd767d662ab89332f6a4285fef07bd8`. All 84 upstream
oracle/no-op controls and 45 Foundry controls retain expected outcomes through
independent offline grading. [Evidence](../benchmarks/evidence/2026-09-19/lemans-upstream-controls/REPORT.md "Repository-only reference; not installed")
records exact images, resolved dependencies, local overrides, failed attempts and
separately attributed corrections. These local Docker results are not a leaderboard
reproduction. Production dependencies, compatibility floors and pilot results are unchanged.

## September 22 reviewed AI work

The existing authorized-tools example adds human-reviewed local ticket resolution with native
Active Record, Active Job and Solid Queue 1.7.0, retaining RubyLLM 1.16.0 and Rails 8.1.3.1.
[Acceptance evidence](reviewed-ticket-resolution-evidence.md) records PostgreSQL 17.11, real Chrome,
process crashes, offline fault controls, installed guidance and corrected failures. This changes
neither the twelve-example catalog nor the core compatibility floor. No live model or agent trial
was run; hosted release CI remains pending a repository destination.

## September 24 native verification and populated adoption

The installed helper supports explicit RSpec selection, retaining Minitest by default.
Independent acceptance locks Rails 7.1.6 / rspec-rails 6.1.5 and Rails 8.1.3.1 /
rspec-rails 8.0.4 with rspec-core 3.13.6 on Ruby 3.4.10. Native example outcomes do not
establish expectation coverage. The separate populated ownership scenario uses PostgreSQL
17, Active Record and upstream packs/Packwerk; it does not require the advanced stack.
[Implementation evidence](evidence/2026-09-24/broader-verification.md "Repository-only reference; not installed")
records controls, corrected failures and limits. The existing release record tracks a fresh
committed candidate separately; hosted CI and live studies remain open gates.

## October audit capture candidate

The local candidate refresh preserves all existing dependency locks and compatibility
floors. Its audit/parity changes use the same Packwerk 3.1.0 and restored pks 0.2.40 binary;
the latter matches the historical SHA-256 above. See
[current candidate evidence](evidence/2026-10-21/release-candidate/README.md "Repository-only reference; not installed")
for source/archive hashes, actual local lanes, failures and retained unchanged corpus
evidence. Hosted CI is explicitly skipped in this authorized scope, not reported as passed.
The candidate remains unpublished; registry publication needs separate user readiness.
