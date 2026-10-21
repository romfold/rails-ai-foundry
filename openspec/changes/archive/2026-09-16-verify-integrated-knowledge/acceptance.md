# Integrated knowledge acceptance — 2026-09-16

The independent recipe is `recipes/domain-knowledge-rag-rom-res-elasticsearch-pgvector`.
Local evidence uses managed Ruby 3.4.10, Rails 8.1.3.1, Bundler 2.6.9, Specify 1.0.0,
rom-sql 3.7.0, RES 3.1.0, Elasticsearch Ruby/API/server 9.3.0 and RubyLLM 1.16.0.
Dependencies are independently locked, including Linux platforms. The application uses
Puma, Turbo, Solid Queue and ROM/SQL pgvector; no Foundry production runtime was added.

Executed from the recipe:

- `foundry setup --specs=spec-kit --agent=codex --greenfield`: initialized pinned upstream tooling.
- `bin/setup`: database preparation and initial search alias succeeded.
- `bin/verify`: real PostgreSQL/Elasticsearch behavior, structural/prompt checks, Packwerk,
  Spec Kit prerequisites and production eager loading succeeded (31 tests / 147 assertions
  at the final composition revision).
- `bundle exec rails test`: latest expanded suite passed **31 tests / 147 assertions**.
  Added actual Solid Queue subprocess delivery, competing optimistic writes and repeated
  failure quarantine/recovery. Earlier assertions cover failed/nested ROM rollback, RES
  crash windows, duplicate/conflicting IDs, concurrent/expired claims, tenant visibility,
  stale embeddings, withdrawal/deletion, unavailable providers, invalid citations,
  failed/caught-up rebuilds, budget expiry and old search revision rejection.
- `bundle exec rubocop`: 62 recipe files clean; root style also passed.
- Root `bundle exec rake test`: 138 tests / 1,075 assertions passed. Skills validated
  (six upstream development skills and eight product skills); contract validation passed
  eight schema assets / 73 cases and ten tests / 142 assertions.
- Service inspection returned PostgreSQL 17.11, pgvector 0.8.6 and Elasticsearch 9.3.0.
- Root `npm run spec:validate`: all 28 current specifications/changes passed strict validation.

Corrected failures: Packwerk identified a root/feature dependency cycle, resolved through
explicit upstream ownership for root jobs and composition initializers. No baseline was
introduced. The search outage test motivated independent destination draining. Ruby 3.4
Packwerk requires `-rstringio`, supplied by the existing Foundry boundary command. The
initial wrong RES migration generator name was corrected to the installed upstream API.

The disposable Docker Desktop VM had low free disk space; local Elasticsearch shard
allocation required explicit cluster-only watermarks (1 GB / 768 MB / 512 MB). This is
recorded in the recipe README, not applied to default Compose settings. No unrelated
Docker images/data were pruned. Elasticsearch emitted a product-verification warning on
initial alias lookup; actual real service requests and assertions succeeded.

Evidence limits: no hosted CI destination exists, so the new independent CI lane is
configured but not claimed run. No paid provider requests, live model-quality evaluation,
throughput claims, deployment or publication. A checked rebuild budget can overrun by an
in-flight request timeout. An ambiguous cutover response requires inspecting the actual
alias. Candidate indexes and inactive embedding versions remain for operator review.
The guided-adoption and benchmark/pilot deliverables remain outstanding in the program.
