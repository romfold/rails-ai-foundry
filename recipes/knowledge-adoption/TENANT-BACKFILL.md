# Populated collection-to-tenant adoption

This separate scenario preserves the default extraction/ROM/integration replay. It uses
PostgreSQL 17, Active Record, packs, packs-rails and Packwerk, with 1,200 existing documents
across three tenants and one deliberately unmapped collection/document. Demo bearer tokens
`demo-a`, `demo-b`, `demo-c` are fixed trusted identities, not production authentication.
Document ownership supplied in a request is ignored; collection ownership is trusted data.

## Reproduce from the installed gem

Use managed Ruby 3.4.10, Node 20.19.0 and PostgreSQL client 17. From the repository root:

```sh
bundle install
npm ci
BUNDLE_GEMFILE=recipes/knowledge-adoption/tenant_app/Gemfile bundle install
docker run --rm --name foundry-tenant-adoption-postgres -e POSTGRES_PASSWORD=foundry -p 127.0.0.1:55545:5432 -d postgres:17
PGPORT=55545 bundle exec ruby recipes/knowledge-adoption/bin/replay --scenario=tenant-backfill
docker stop foundry-tenant-adoption-postgres
```

The selector is contributor tooling, not a Foundry command. It builds/installs the gem,
replays `packs/` and `components/` in isolated applications, and retains failed checkpoints
for diagnosis. Commands and evidence identify the exact disposable databases. Never point
this fixture at business data: its seeds and tests intentionally reset their own tables.
The application needs no checkout at execution time; only the contributor replay reads the
fixture and pinned workflow validator. Locks, snapshots and evidence stay in its temporary
workspace. Historical OpenSpec bytes, custom skills, receipts, instructions and accepted
debt are checked for preservation.

## Deployable checkpoints

1. Characterize collection-authorized create/edit/delete, IDs, revision conflicts, content
   and timestamps. Unmapped collections remain inaccessible.
2. Extract Knowledge, retain Active Record/tables, and repair public callers. An intentional
   Packwerk violation must fail before explicit debt review and repair. This is independently
   useful; it does not require tenant-column adoption.
3. Apply the additive root expansion migration. Deploy compatible writers that derive the
   tenant from the collection and participate in the shared writer gate. Keep legacy reads.
   Confirm all old web/job writers have stopped; ownership transfers are outside this example.
4. Start/resume keyset batches (at most 250 rows). A locked progress row serializes workers;
   document changes, unresolved IDs and cursor commit together. Collection locks prevent a
   repair racing a batch; document-only write locks let unrelated writes continue. Repeating
   work after a crash never skips an uncommitted batch. New compatible writes already own tenants.
5. Review unresolved IDs and repair the trusted collection mapping explicitly. Never assign
   a fallback tenant. Retry the documented document/collection pair; conflicting existing
   ownership aborts without advancing the cursor. Investigate deleted unresolved rows explicitly.
6. Install `NOT VALID` presence and composite ownership constraints in a short transaction;
   commit before validating existing rows. Validation uses PostgreSQL staged facilities
   outside the final gate. A failed validation leaves enforced-but-unvalidated constraints
   available for repair/retry. Progress/counts alone cannot prove the invariant.
7. Cut over only after successful validation. An exclusive advisory writer gate has a
   five-second acquisition timeout and ten-second checked budget. No backfill/full scan
   runs inside it. SQL has a remaining-budget timeout; an in-flight operation/commit can
   overshoot before the next check. Failure rolls back read selection and releases the gate.

Application tasks, from a replayed expanded application with its database/environment:

```sh
bundle exec rails tenant_adoption:status
OLD_WRITERS_STOPPED=yes bundle exec rails tenant_adoption:backfill
OLD_WRITERS_STOPPED=yes bundle exec rails tenant_adoption:resume
DOCUMENT_ID=1201 REVIEWED_COLLECTION_ID=4 bundle exec rails tenant_adoption:repair
bundle exec rails tenant_adoption:validate
bundle exec rails tenant_adoption:cutover
bundle exec rails tenant_adoption:rollback
```

`repair` rechecks an already-reviewed trusted collection; it does not choose a tenant.
Status exposes at most 50 unresolved IDs/reasons and a total count, without document bodies.
Batch SQL/locks have 10/5-second timeouts; validation has a 60-second statement timeout.
Rows retain timestamps/revisions because ownership backfill changes only the new column.

## Rollback and evidence

Before persistence changes, revert the extraction patch against the unchanged database.
After expansion, return to the compatible legacy-read release using `rollback`; keep
compatible writers and additive columns, ownership data, progress and constraints. Do not
roll back to pre-expansion writers after constraints are installed. No destructive schema
reversal or automatic ownership transfer is provided.

Acceptance covers real concurrent writers, duplicate workers, process death before/after
commit, fresh schema loading, unresolved/inconsistent ownership, lock/budget failures and
continuity after cutover. Four offline controls deliberately assign a default owner, skip
a batch, activate prematurely or bypass authorization; each must fail a behavioral assertion.
See the current local verification evidence before treating a checkpoint as complete.
