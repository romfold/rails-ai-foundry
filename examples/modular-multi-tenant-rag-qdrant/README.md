# Modular multi-tenant RAG with Qdrant

The focal context is [knowledge](packs/knowledge/foundry.yml). PostgreSQL owns documents and embedding versions;
Qdrant is a rebuildable external read model. The app owns the small REST boundary and independent bundle.

```sh
docker compose up -d --wait
bundle install
bin/setup
bin/verify
bundle exec rubocop
bin/rails server
# After ingestion, build or refresh the derived index:
bundle exec ruby packs/knowledge/script/rebuild.rb
```

POST `/documents` with `Authorization: Bearer demo-a` and JSON title/body; ingestion commits authoritative
content and reports pending projection. Run rebuild, then GET `/search?q=refund` with the same authorization.
The response quotes retrieved text and carries revision-specific document citations. DELETE `/documents/:id`
immediately prevents further evidence from that document, even before the next projection rebuild.
Demo-b owns another tenant; replace these public demo identities with production authentication.

Qdrant filters tenant, version and tombstones before ranking. PostgreSQL then rejects stale revisions and checks
ownership again. Embeddings are deliberately tiny, deterministic three-topic vectors; extractive answers make no
model requests. Inject a real embedding provider with an explicit version and use a matching collection dimension
when adapting this recipe. The local test corpus establishes isolation/relevance mechanics, not model quality.

Rebuild backfills a fresh collection, catches concurrent changes, pauses writers for a final pass, validates all
payloads/vectors and swaps the alias atomically. This bounded example pauses writes during final validation and
keeps previous collections; size that cost before deploying. Do not cut back to an old collection without reconciling
intervening authoritative writes. Failed candidates remain for inspection and can be removed after diagnosis.
A failed external index never deletes PostgreSQL content; rerunning rebuild restores the read model.

Current writes are synchronous PostgreSQL operations; index refresh is an explicit operator/scheduler command.
Run it after ingestion or on a schedule. Continuous incremental indexing can use the separate outbox example.
Keep [the living contract](specs/001-reference/spec.md), plan and tasks reconciled. Spec Kit checks artifact presence;
real Qdrant/PostgreSQL tests, Packwerk and production loading provide the recorded evidence.
