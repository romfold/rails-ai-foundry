# Domain knowledge with ROM, RES, Elasticsearch and pgvector

An independently bundled Rails application built on **Rails, packs, packs-rails and
Packwerk**. Its focal context is [Knowledge](packs/knowledge/foundry.yml); the other
contexts own access, search and answering. See the installed [application settings](config/foundry.yml)
and upstream package files for architecture. This advanced recipe is outside the
unchanged twelve-example catalog.

## Run locally

Use Ruby 3.4.10, Bundler 2.6.9, PostgreSQL client 17 and Docker Compose. From this directory:

```sh
bundle install
docker compose -p foundry-integrated-knowledge up -d --wait
bin/setup
bin/rails server -b 127.0.0.1 -p 3030
```

In another terminal, run `bin/jobs`. Visit `http://127.0.0.1:3030`, sign in with `demo-a`,
create a document, publish it, and watch delivery status. Search and answer forms use
the published content. `demo-b` is a different tenant and cannot access those documents.
The UI uses Rails views, Turbo and Puma. Solid Queue periodically wakes the application
poller; pending database delivery rows survive lost wake-ups.

**Authentication is deliberately a local demonstration.** `DEMO_TOKENS` maps opaque
bearer tokens to tenant identifiers. Tokens are checked on every access and tool call;
session login rotates the session. Replace this with trusted production identity before
deployment. The development database password and unsecured loopback Elasticsearch
service are disposable local settings.

## Data and recovery

Document state and outbox intent commit through the same ROM gateway transaction.
Native `Dry::Operation` failures explicitly roll back, including savepoints. PostgreSQL
remains authoritative; RES holds integration events, not authoritative event streams.
Events contain identifiers, revisions and schema versions, without document bodies.

A publisher appends stable RES event IDs after commit. Duplicate identity, payload and
stream membership must agree before acknowledgment. Each projection has its own
persisted lease, retry schedule and acknowledgment. Expired claims receive a fresh
fencing token; obsolete workers cannot acknowledge them. Five reported failures quarantine
work. Inspect application delivery rows before explicitly repairing a poison row:

```ruby
Rails.configuration.x.knowledge.queue.repair(delivery_id)
```

Repeated abrupt process deaths are recovered by lease expiry and are not automatically
classified as poison. Scheduling is only a wake-up. The poller handles each destination
independently, so a search outage does not starve vector delivery.

Search and vectors are disposable projections. Current authoritative visibility is
rechecked on reads and citations. Deleted documents retain a minimal tombstone revision;
Elasticsearch external versions reject older writes. Embeddings are computed outside
writer transactions and rechecked before storage. pgvector uses ROM/SQL, without Neighbor.

In a Rails console, rebuild with:

```ruby
Rails.configuration.x.search.rebuild_search
Rails.configuration.x.search.rebuild_vectors(version: 'demo-v2')
```

Rebuilds persist candidate identity, journal fences, batch options, checkpoints, manifests
and leases. Resume the same run after interruption; only one live run per destination is
allowed. Backfill and validation use pages of at most 250 rows, and Elasticsearch bulk
requests are capped at 1 MiB. Provider calls remain outside writer transactions. The final
gate requires no pending deltas before activation and performs no full-corpus scan.
Its checked ten-second budget has bounded request/SQL timeouts; in-flight requests can
overshoot. Unknown alias outcomes freeze candidate mutation and require reconciliation.

The [operator runbook](../../docs/knowledge-operations.md) covers start/status/resume/cancel,
dry-run cleanup, upgrade/rollback and telemetry. It also explains the known global writer
gate limitation, exact-vector database scan costs and conservative journal retention.
Document pages default to 50 (maximum 100); retrieval returns five authorized documents
after at most 100 candidates and explicitly reports an incomplete response.

## AI and measurements

Normal execution uses deterministic `Search::DemoEmbeddings` and `Answering::DemoAnswer`.
Native `Search::ProviderEmbeddings` and `Answering::ProviderAnswer` use application-owned
aliases in [config/ai.yml](config/ai.yml) and explicit constructor injection. Merely running
setup, tests or workers does not opt into paid provider requests. Prompt, schema and tool
contracts belong to the Answering pack. Source-relative prompt lookup works independently
of the current directory. Cited output must reference retrieved, still-visible revisions;
this does not establish the semantic truth of arbitrary generated prose.

Application notifications ending in `.knowledge` emit delivery lag, attempts, retry/poison
state, retrieval duration and provider failures to Rails JSON logs. They deliberately omit
credentials, document content, questions and exception messages. Attach an application-owned
metrics subscriber for deployment-specific monitoring.

## Package ownership

The root package owns dependency-free Rails base classes and shared UI. Two upstream shell
packages own root `app/jobs` orchestration and `config/initializers` composition, so feature
controllers can depend on the root without a cycle. These are shell groupings, not additional
Foundry business contexts. [packs.yml](packs.yml) makes discovery explicit. No accepted debt,
custom loader, container or Foundry application runtime is involved.

## Verification and evidence

```sh
bin/verify
bundle exec rubocop
```

Acceptance uses only named loopback databases and the disposable Elasticsearch endpoint.
It verifies HTTP delivery, transactional rollback, tenant isolation, native RES replay,
concurrent claims, expired leases, poison repair, projection crashes, current citations,
stale embeddings, deletion, failed rebuilds and deterministic RubyLLM adapter contracts.
Production eager loading and Packwerk run independently of structural checks. The upstream
Spec Kit 1.0.0 artifacts live in `.specify/` and `specs/001-knowledge`; prerequisite validation
is separate from executable behavior.

The independent lock pins Rails 8.1.3.1, rom-sql 3.7.0, RES 3.1.0, Elasticsearch Ruby/API
9.3.0, RubyLLM 1.16.0 and ruby_llm-schema 0.4.0. Compose pins Elasticsearch server 9.3.0
and a pgvector/PostgreSQL 17 image digest. Linux lock platforms are included. Exact final
acceptance and bounded runtime samples are in the
[measurement record](../../docs/knowledge-operations-evidence.md). Hosted CI and live
model-quality evaluations have not been run.

Local service note: September 17 acceptance used isolated 1 GiB tmpfs data directories for
each disposable service because the existing Docker Desktop disk was almost full. Default
Compose settings retain disk-backed storage and normal Elasticsearch watermarks. No
unrelated images or user data were pruned. Runtime samples describe this temporary setup.
