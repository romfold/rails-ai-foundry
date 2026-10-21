# Knowledge operations acceptance — September 17, 2026

This record covers the existing integrated recipe and shared verification guidance. No
agent trial, live application-provider evaluation, deployment or hosted CI run occurred.
The original September 16 pilot and its separately attributed grader correction are unchanged.
Application implementation is commit `04d54c3`; packaged guidance and adoption controls are
commit `5dd6ee1`. The verified 21-task change is
[archived here](../openspec/changes/archive/2026-09-17-bound-and-resume-knowledge-projections/acceptance.md "Repository-only reference; not installed").

## Environment and provenance

- Host: Apple M1 Max, 32 GiB RAM, arm64 macOS; Docker reported 6,228,185,088 bytes RAM.
- Ruby 3.4.10, Bundler 2.6.9, Node 20.19.0; Spec Kit 1.0.0 and OpenSpec 1.12.0.
- Recipe lock: Rails 8.1.3.1, rom-sql 3.7.0, RES 3.1.0, Elasticsearch Ruby/API 9.3.0,
  RubyLLM 1.16.0; PostgreSQL 17.11 with the recipe's pinned pgvector image.
- Elasticsearch server 9.3.0 image ID `fd6c2c3bfddb`; pgvector/pg17 image ID `9f6f5e8f6bf6`.
- Recipe lock SHA-256: `9103eb62de506b9cef2765ead7b8fbcf78053efd80e4ae00d493c203567d876d`.
- Final measured source SHA-256:
  `210bb66491c826b1b16e7139ed5eb91ba1b6b1f07c34e4acb1c97f9c7ef0e71c`.
  The runner hashes sorted relative paths and file SHA-256 values under application,
  packs, configuration, migrations, lib, script and test/support. Docs are excluded.

Local Docker disk exhaustion initially caused Elasticsearch shard/write failures. Rather
than prune unrelated data, final acceptance used separate **1 GiB tmpfs** data directories
for each disposable service. The committed Compose file retains normal disk-backed storage.
The temporary override was:

```yaml
services:
  postgres:
    tmpfs:
      - /var/lib/postgresql/data:size=1073741824
  elasticsearch:
    tmpfs:
      - /usr/share/elasticsearch/data:size=1073741824,uid=1000,gid=0
```

```sh
docker compose -p foundry-integrated-knowledge -f compose.yml -f /private/tmp/foundry-knowledge-services.yml up -d --wait --force-recreate
```

Commands used managed Ruby/Node in PATH and PostgreSQL 17 client binaries. Locked gems
were restored under `/private/tmp/foundry-knowledge-bundle`; the recipe's ignored local
Bundler configuration pointed there. Root commands used that BUNDLE_PATH. Workflow tests
also used `/private/tmp/foundry-spec-kit/bin` and the repository's `node_modules/.bin`.
These temporary paths are local setup details, not required application configuration.

## Executed acceptance

| Scope / command | Result |
| --- | --- |
| Recipe `bin/verify` | 59 tests, 258 assertions; source/prompt checks, Packwerk and production eager loading passed |
| Recipe `bundle exec rubocop` | 80 files, no offenses |
| Root `bundle exec rubocop` | 643 files, no offenses |
| Operator `projections:start`, `status`, `resume`, `cancel`, `cleanup` | Real Rake smoke run progressed queued → backfilling → cancelled; cleanup reported `dry_run: true` |
| Root `bundle exec rake test` | 143 tests, 1,108 assertions, passed |
| Root `bundle exec rake test:package` | 6 tests, 398 assertions, passed |
| Root `bundle exec rake test:workflows` | 3 tests, 39 assertions, both pinned tools passed |
| Root AI lane with `BUNDLE_GEMFILE=gemfiles/ai_rails_8_1.gemfile bundle exec rake test:ai` | 8 tests, 60 assertions, offline passed |
| Root `bundle exec ruby recipes/knowledge-adoption/bin/replay` | Both `packs/` and `components/`; 40 test executions, 290 assertions, passed |
| Root `npm run contracts:validate` | 10 tests, 142 assertions; eight schemas and 73 configuration/report cases passed |
| Root `ruby script/validate_skills` | Six upstream workflows and eight product skills passed |
| Root `bundle exec ruby script/validate_examples.rb` | Twelve catalog applications validated |
| Skill creator `quick_validate.py` for add-feature, event-workflow and verify | All three passed |
| `npm run spec:validate` | 32 strict items passed before archive; 31 after archive |

The recipe's process tests launch a real child Rails process, synchronize through pipes,
kill it after destination persistence or alias mutation, expire ownership in the disposable
database, and resume the same run. They verify lost checkpoints, actual alias selection and
post-fence deletion. Other cases cover partial bulk errors, expired/delayed workers, source
changes behind the page cursor, sequence gaps, unavailable providers, stale embeddings,
corrupt candidates, lost wake-ups, quarantine/repair and guarded stale alias requests.

The additive-upgrade test reconstructs the pre-upgrade schema inside a disposable database
transaction, applies all four migrations, compares documents, outbox, RES events, vectors
and selections, then rolls back the test transaction. This is a test technique, not the
production rollback procedure: the [runbook](knowledge-operations.md) retains operational tables.

Installed first-feature controls accept direct model access, delegated lookup and relocated
same-pack queries through their HTTP behavior. A deliberately wrong rendered amount passes
source/Packwerk checks and fails the HTTP assertion (one failure, zero errors). Those expected
inner failures are successful negative controls. Customized recovery references and receipts,
all eight skill identities, workflow `none`, OpenSpec history and accepted debt are preserved.
[Adoption snapshot hashes](evidence/knowledge-operations/adoption.json "Repository-only reference; not installed") identify the replayed
checkpoints; the later final gate-budget/telemetry refinement is covered by recipe acceptance.

## Bounded runtime samples

From the recipe, in separate fresh processes and serially after other acceptance work:

```sh
RAILS_ENV=test /usr/bin/time -l bundle exec rails runner script/measure_projections.rb 1000
RAILS_ENV=test /usr/bin/time -l bundle exec rails runner script/measure_projections.rb 10000
```

Each scenario has a 600-second timeout and only accepts the named disposable test database.
The deterministic seed is 17, dimensions are 1,536, tenant distribution is 80% / 15% / 5%.
Fixture seed represents existing committed documents; it does not measure business write
ingestion. Each sample rebuilds search with an injected post-write/pre-checkpoint failure,
resumes it, rebuilds vectors, warms retrieval and takes five measurements. Retrieval calls
Search's public API, not HTTP; RSS includes the Ruby process, not the Docker services.

The raw reports include query plans, per-stage allocations/query counts, notification maxima,
source/lock hashes and `/usr/bin/time -l` output. Serialized row/payload bytes are not Ruby heap
size; RSS captures whole-process memory separately. Exact vector plans still process 800 or
8,000 authorized rows while returning 20 candidates to Ruby. This is bounded materialization,
not constant database work or a high-load certification.

| Final sample | 1,000 documents | 10,000 documents |
| --- | ---: | ---: |
| Status | Passed | Passed |
| Whole process wall time | 10.36 s | 84.93 s |
| SQL statements, including transaction/control queries | 9,522 | 92,898 |
| Maximum snapshot rows / serialized bytes | 250 / 66,753 | 250 / 67,253 |
| Maximum bulk rows / request bytes | 250 / 72,752 | 250 / 73,252 |
| Maximum vector-validation rows / serialized bytes | 250 / 788,750 | 250 / 788,750 |
| Retrieval candidates / returned documents | 20 / 5 | 20 / 5 |
| Peak Ruby RSS | 194.11 MiB | 248.00 MiB |
| Allocations across recorded stages | 1,509,091 | 14,235,314 |
| Warm retrieval p50 / p95 (five samples) | 7.885 / 13.217 ms | 23.177 / 24.063 ms |
| Search rebuild including recovery | 1.052 s / 950 docs/s | 10.616 s / 942 docs/s |
| Vector rebuild | 7.512 s / 133 docs/s | 71.523 s / 140 docs/s |
| Resume after controlled interruption to complete | 0.965 s | 10.536 s |
| Maximum measured final-gate duration | 24.213 ms | 25.462 ms |

Raw final outputs: [1,000](evidence/knowledge-operations/1000.txt "Repository-only reference; not installed") and
[10,000](evidence/knowledge-operations/10000.txt "Repository-only reference; not installed"). Recovery duration starts immediately after
the injected failure and includes the remaining rebuild; it excludes production scheduler
delay and the 30-second lease wait tested separately by process recovery. Neither final
sample timed out. Their combined wall time is 95.29 seconds; preliminary and diagnostic
measurement execution also remained below the thirty-minute overall budget. Every invocation
enforced its ten-minute limit. Query counts expose the remaining per-record vector persistence
cost; the result is not evidence that ingestion is optimized for high load.

Pre-final samples are retained separately as
[1,000 before final checks](evidence/knowledge-operations/1000-before-final-budget-check.txt "Repository-only reference; not installed")
and [10,000 before final checks](evidence/knowledge-operations/10000-before-final-budget-check.txt "Repository-only reference; not installed"),
with source hash `27c99f3020a2a194fbcd8b177ee61d9e618b5bbfed05ec4702971e364e94340e`.
They preceded the extra alias budget checks and vector-page telemetry and are not the final
measurement. Earlier 1,000-row diagnostic runs also passed but overlapped other acceptance;
they are excluded from the comparison. No timeout is hidden or counted as success.

These samples validate resource bounds and recovery at the stated sizes. There is no matched
old/new speedup claim: the old implementation lacks the durable journal/run semantics needed
for the same recovery scenario. Five local latency samples do not estimate production tails.
Keep the global writer gate, conservative retention, demo identity and tmpfs environment in
mind when applying this evidence. Hosted release CI awaits a repository destination.

## Resolved failures and warnings

Initial service acceptance failed on Docker disk watermarks; disposable tmpfs resolved it.
Full packaged acceptance initially failed because generated Rails default dependencies were
missing. `bundle exec ruby script/prepare_acceptance` restored them into the temporary gem
directory; the rerun passed. Real lease testing exposed local-time decoding of UTC database
timestamps; explicit UTC decoding and lease-replacement tests fixed it. A delayed-writer test
initially observed Rails query-cache data; its synchronization query now runs uncached.
RuboCop failures from new instrumentation were corrected without disabling checks.

Upstream parser/Ruby-version, MultiJSON deprecation and Elasticsearch product-check warnings
remain visible in logs. The raw pgvector migration comparison uses string decoding for its
unknown Active Record vector OID; runtime vector operations use ROM/SQL as intended. None of
these warnings was treated as behavioral proof, and all final test commands exited zero.
