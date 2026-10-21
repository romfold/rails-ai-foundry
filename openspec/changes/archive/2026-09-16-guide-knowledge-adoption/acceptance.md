# Guided adoption evidence — 2026-09-16

`bundle exec ruby recipes/knowledge-adoption/bin/replay` passed for both `packs/` and
`components/`. Each of the five behavioral checkpoints ran four tests / 29 assertions,
for 40 executions / 290 assertions across both roots. Every checkpoint also verified
ordinary Rails loading and an existing record's identity, tenant, revision, content and
timestamps. The runner validated unchanged OpenSpec artifacts and called the installed
archive's assessment commands, including selected-context refactoring.

Packwerk detected the intentional private facade access before repair. Normal checks
preserved the explicitly reviewed temporary baseline. The disposable audit reported
exactly that identity resolved, no new debt and unchanged source; the replay then removed
only the reviewed baseline. Both final applications passed source/prompt and Packwerk
checks. Real PostgreSQL/RES/Elasticsearch/pgvector backfill made the pre-existing tenant
record available to offline cited answering.

`replay-evidence.json` records the built-gem hash, workflow/source hashes, installed-gem
provenance, reports and snapshot locations. `$REPLAY_ROOT` normalizes the original local
path `/tmp/redacted/T/foundry-knowledge-adoption-20260916-33204-cq9zca`.
This is recorded replay evidence, not a synthetic passing result. The snapshots and separate
named databases remain available locally. Shared integration dependency versions are the
composition recipe's locked versions; fixture OpenSpec is independently pinned to 1.12.0.

Corrected failures:

- Normalize macOS `/var` and `/private/var` paths for installed-gem provenance.
- Decode UTF-8 Packwerk output before parsing JSON in a US-ASCII parent process.
- Preserve the original HTTP page heading when adding integrated delivery.
- Disable automatic test-schema recreation in this fixture only; replay manages migrations
  explicitly and still rejects pending migrations. Continuity checks run before and after tests.
- Include the new checkpoint reference in installed skills, and update the expected complete
  installation size from 73 to 81 files. Eight skill identities remain unchanged.

Focused guidance/refactor tests passed nine tests / 48 assertions before broader validation.
All four modified skills passed skill-creator quick validation using the existing Specify
Python environment (the system Python lacked PyYAML); the repository skill validator passed.
The broader packaged suite passed six tests / 370 assertions before the final installer fix;
a fresh installed-gem replay then exercised the corrected gem. Final core/style/contract
results will be appended after their current runs finish.

Limits: no hosted CI or publication. The walkthrough is application-specific, uses disposable
loopback services and does not implement a general migration command. No live AI provider
requests or coding-agent trials occurred as part of adoption acceptance.

Final validation: core 143 tests / 1,105 assertions; RuboCop 586 files, no offenses;
contracts 10 tests / 142 assertions, eight schemas / 73 cases; six development and eight
product skills; strict OpenSpec 30 items passed. Optional AI acceptance passed eight tests /
60 assertions, including a freshly built archive and generated consumer. Workflow acceptance
initially failed because the pinned OpenSpec binary was absent from PATH; adding the local
node_modules/.bin alongside Specify resolved the environment issue. The rerun passed three
tests / 39 assertions for Codex, Claude and Cursor with preservation and explicit opt-out.
No application-provider calls were made. Hosted CI remains pending a repository destination.
