# Knowledge adoption checkpoints

This executable journey starts with an ordinary Rails application and adopts one useful
business boundary before changing persistence or adding integrations. Foundry supplies
read-only guidance and checks on top of Rails, packs, packs-rails and Packwerk.

The [starting application](starting_app/) has its own Ruby and OpenSpec locks. It uses
Active Record and existing `knowledge_documents` tables. Its small demo authentication
matches the integrated knowledge recipe: `demo-a` and `demo-b` identify separate tenants.
The checked-in workflow history is explicitly synthetic fixture history whose bytes must
survive replay.

## Replay

From the Foundry repository root, use managed Ruby 3.4.10, Bundler 2.6.9, Node 20.19.0,
PostgreSQL client 17 and the disposable composition services:

```sh
bundle install
npm ci
BUNDLE_GEMFILE=recipes/knowledge-adoption/starting_app/Gemfile bundle install
BUNDLE_GEMFILE=recipes/domain-knowledge-rag-rom-res-elasticsearch-pgvector/Gemfile bundle install
docker compose -p foundry-integrated-knowledge -f recipes/domain-knowledge-rag-rom-res-elasticsearch-pgvector/compose.yml up -d --wait
bundle exec ruby recipes/knowledge-adoption/bin/replay
```

Preparation installs dependencies; replay resolves only locally available gems. The harness
builds the current gem into a temporary directory, installs that archive in an isolated gem
home, and proves commands load it rather than the source checkout. No application provider
requests run. PostgreSQL/Elasticsearch acceptance uses loopback services; the harness creates
separate `foundry_adoption_<process>_<root>` databases and index names.

It replays both `packs/` and `components/`, preserving existing workflow history and seeded
records. Every behavioral checkpoint runs the same HTTP/authorization/rollback tests and
ordinary Rails eager loading. The runner retains source snapshots, independent resolved
locks, hashes and evidence outside the repository. Failures preserve the working application
for diagnosis. It never operates on a user-supplied application.

## Checkpoints

| Checkpoint | Change and evidence |
| --- | --- |
| 01 Characterize | Existing endpoints, tenant authorization, revision errors, failed transactions and view/session delivery |
| 02 Assess | Installed `foundry adopt` returns specific read-only guidance and preserves all input files |
| 03 Extract | Move Knowledge into the existing package root, retaining Active Record and tables; behavior still passes |
| 04 Public API | Packwerk first rejects private facade access; export the facade, audit resolved identities, explicitly remove only the reviewed temporary debt |
| 05 ROM | Replace this application's persistence code separately; verify the same existing IDs, revisions, ownership, values and timestamps |
| 06 Integrations | Add RES/outbox, search, vectors and answering; backfill pre-existing published records and verify cited retrieval |

The temporary accepted-debt checkpoint is deliberately explicit: the harness first asserts
a real privacy violation, generates its one reviewed baseline in the disposable application,
verifies ordinary checks preserve it, then audits the repair in another disposable copy.
This demonstrates reviewed debt resolution. Normal `foundry adopt`, refactor assessment and
checking never accept or regenerate debt.

The extraction step has no ROM, RES, Elasticsearch, pgvector or RubyLLM dependency. Stopping
after public API repair is a useful adoption outcome. Later changes adapt source from the
separately verified integrated recipe; they are application-specific walkthrough code.

## Rollback and continuity

Each verified source snapshot can replace the disposable application's code at its corresponding
checkpoint. Keep the same `ADOPTION_DATABASE`, installed gem home and resolved bundle when
re-running it. Before the integration checkpoint, the existing table layout stays unchanged;
the ROM-to-Active-Record rollback changes code without converting business data. Integration
migrations add tables and the vector extension; earlier code can ignore these additions.
Stop the worker before reverting code and retain pending delivery rows for recovery. Do not
drop the authoritative documents table or treat reverting code as reverting later business writes.

The harness migrates explicitly. Rails' automatic test-schema maintenance is disabled only in
this fixture because it can recreate a test database after schema changes; pending migrations
still fail explicitly. Continuity assertions run before and after behavioral tests so a reset
cannot masquerade as successful migration.

Keep failed snapshots and databases until the failure is understood. Cleanup applies only to
the exact disposable names printed by this run, never existing application databases or other
Docker resources. This is not a general-purpose production migration or rollback tool.

## Evidence status

Complete local replay passes for both roots: five behavioral checkpoints per root, each
with four tests / 29 assertions (40 executions / 290 assertions), plus installed-gem
assessments, actual failing/repaired Packwerk boundaries, data continuity, workflow history
and real search/vector/citation checks. Portable hashes and report evidence are recorded
in the `guide-knowledge-adoption` OpenSpec change. Final broader validation is tracked there. Hosted CI remains pending until a repository
destination exists. No coding-agent productivity conclusion follows from this walkthrough.

## Populated ownership scenario

The separate [tenant-backfill runbook](TENANT-BACKFILL.md) demonstrates safe ownership expansion while compatible writes continue, then a bounded read cutover. Use `--scenario=tenant-backfill`; the default replay above is unchanged.
