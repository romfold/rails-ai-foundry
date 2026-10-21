# Current local release-candidate verification

Verification began September 24, continued September 25 after a host sleep/wake interval,
and resumed September 28 after Docker became available again.

Candidate: `10d4d9b357fba462c86fea568286b4fb4216ba8b`.
The sweep started at `73c13b457e8d8b5c9efa65659879dabdb009af05` in a clean disposable
Git archive. Commit `017ac49` corrects a packaging test's assumption about Rails 7.1's
exit status for an absent generator; the exact diagnostic and unchanged-files assertions
remain, and the corrected test passes on all three declared compatibility lanes.
Commit `c5172fd` then fixes RSpec shared-example attribution: only the including file owns
the executed example. A selected definition file cannot claim an unselected includer's
examples. The regression demonstrably fails against the old formatter.
Commit `10d4d9b` then changes the advanced recipe health check to TCP readiness, so
the temporary initialization server cannot satisfy `compose up --wait`. The documented
startup/test sequence passes directly on a fresh service. This unshipped Compose change
leaves all 159 resources and the entire gem byte-identical to `c5172fd`; the clean rebuild
uses the existing deterministic package epoch (`SOURCE_DATE_EPOCH=315619200`).

The final clean archive builds gem SHA-256
`608d0e69af3d2e9f82a1de8e1e94dfae3d3292d6b82f167247e557fb843dc097`.
All 159 packaged resources match that committed source. Relative to the first candidate,
158 resource hashes are unchanged; only `rspec_formatter.rb` changes. The 34 tracked
locks and accepted-debt files remain byte-identical. The first two candidates built gem
`8a5303db00b6beb069ee7d25f90621571fdf39000a5f780f1632adad6da1772a`.
[Provenance](provenance.json) records each source/archive/gem/resource/dependency identity.
[Commands](commands.json) records actual commands, statuses, elapsed times and raw-output
hashes, including unsuccessful attempts. `$CANDIDATE`, `$HOME` and `$TMP` are portable
labels, not runnable fixed directories.

The final formatter changes only the explicit RSpec execution path. Both RSpec installed
lanes and final core/package/workflow/AI/distribution checks are repeated. The twelve
Minitest applications, adoption/knowledge recipes, compatibility matrix and offline
benchmark sweeps remain attributed to the earlier candidate: their implementation,
tests, locks, Minitest verification, instructions and grading sources are unchanged.
Their old installed-gem hashes are retained rather than relabeled as final-gem runs.
Later specification archival and evidence changes do not change distributed resources.

## Local lane results

| Lane | Result |
| --- | --- |
| Ruby 3.3.10 / Rails 7.1.6 / Bundler 2.5.18 | Core 197 / 2,137; corrected packaged acceptance 6 / 484; offline AI 8 / 60 |
| Ruby 3.4.10 / Rails 8.1.3.1 / Bundler 2.6.9 | Core 197 / 2,137; original packaged acceptance 6 / 486; offline AI 8 / 60; corrected native workflow 1 / 69 |
| Ruby 4.0.6 / Rails 8.1.3.1 / Bundler 4.0.10 | Core 197 / 2,137; original packaged acceptance 6 / 486; offline AI 8 / 60; corrected native workflow 1 / 69 |
| Final managed candidate | Core 197 / 2,137; package 6 / 484; workflows 3 / 39; offline AI 8 / 60 |
| RSpec Rails 7.1 / 8.1 independent bundles | Final candidate: each 15 / 385, including installed upgrade, real requests/browser and faulty controls |
| Native workflows | 3 / 39; installed `new` with Spec Kit and OpenSpec each 1 / 54 |
| Installed AI journey | 2 / 227, including upgrade recovery and application acceptance |
| Populated ownership adoption | Both roots: 13 / 67 plus HTTP characterization, four rejected controls, fresh-schema replay and preserved application artifacts |
| Original adoption journey | Both roots pass extraction, Active Record, ROM and integrated feature checkpoints |
| Knowledge composition/recovery | 59 / 258; loading, Packwerk, prompts and 80 Ruby files clean |
| Advanced composition | Current committed TCP health check: 7 / 30; 6 Ruby files clean |
| FlowNodes / Langchainrb | 6 / 29 and 7 / 34; respective independent style checks pass |
| Experimental vectors | Contracts 5 / 33; real pinned Weaviate 1 / 9; 8 Ruby files clean |
| Evidence recipe | Evaluation 7 / 39; benchmark 2 / 5; offline evaluation/runtime sample and style pass |
| Adoption parity | Real Packwerk 3.1.0 / pks 0.2.40 agree; two retained identities, resolved/new-debt controls and original bytes preserved |
| Structural/distribution | 828 Ruby files clean; six development/eight product skills; twelve apps; contracts 10 / 142 plus eight schemas / 73 cases; zero privacy findings; strict OpenSpec 38 / 38 |
| Benchmark contributor/integrity/browser | 82 / 654; integrity 7 / 21; valid browser passes and caller/browser faults are rejected |
| Foundry / reviewed-AI controls | 45 / 45 independent controls accepted (24 valid, 21 faulty), native parity; reviewed AI 14 / 14 accepted (four valid, ten faulty/no-op) |
| Upstream controls | 84 / 84 accepted: 42 passing references and 42 rejected no-op submissions; native/independent agreement, no missing or duplicate pairs |

Counts are outer acceptance tests / assertions unless stated otherwise. RSpec rows
report the acceptance harness assertions, not native RSpec expectation counts. Expected faulty-control failures
inside passing harnesses are not silently removed. RSpec native expectation counts remain
unavailable. Full application verification and browser behavior are independent of
structural checks and agent completion messages.

[Control reports](benchmark-reports.json) retain both the unsuccessful original upstream
report and the accepted result. The [attempt selection](benchmark-attempt-selection.json)
identifies all 49 replaced attempts: one native interruption and 48 independent Docker
failures. It records source hashes and confirms unchanged native artifacts for the six
reference retries. The other 35 accepted pairs are retained without rerunning them.
The [frozen inputs](benchmark-inputs.json) record the pinned corpus and image identities.

## Twelve independently bundled applications

Each application ran setup, behavior, loading, package boundaries, selected workflow
prerequisites and RuboCop with its locked bundle and disposable services.

| Application | Behavioral result |
| --- | --- |
| domain-event-sourced-ledger-rails-event-store | 5 / 21 |
| modular-event-pipeline-kafka-karafka | 5 / 27 |
| modular-graphql-async-dataloader | 5 / 24 |
| modular-legacy-adoption-packwerk | 3 / 18 plus independently useful extraction replay |
| modular-multi-tenant-rag-qdrant | 4 / 24 |
| modular-opensearch-cqrs | 8 / 43 |
| modular-realtime-voice-rabbitmq | 8 / 81 |
| modular-transactional-outbox-postgresql-sidekiq | 5 / 30 |
| rails-native-agent-tools-structured-output-rubyllm | Baseline 37 / 132; HTTP 3 / 12; browser 3 / 23; queue/recovery 15 / 45 twice; four rejected controls |
| rails-native-ai-chat-rubyllm-hotwire | 5 / 38 |
| rails-native-nextjs-graphql | 2 / 5 plus production frontend build |
| rails-native-rag-pgvector | 12 / 93; original two-second SQL bound retained |

## Failed attempts and corrections

- Docker became unavailable during the independent upstream sweep on September 25.
  Thirty-six reference verifications completed successfully; six reference checks and
  all 42 no-op checks recorded infrastructure errors. Native no-op execution had already
  completed successfully. Recovery reuses unchanged native patches in new independent
  verification directories; original failed results remain preserved. All six reference
  retries and 42 no-op retries completed on September 28, with the original two-CPU,
  6,228,185,088-byte Docker limits. The combined report accepts all 84 unique pairs with
  zero infrastructure errors, disagreements, missing pairs or duplicates.

- The upstream export/import reference verifier spanned September 24 19:47 UTC to
  September 25 07:30 UTC and ended without a reward (exit 124). It is retained as an
  invalid infrastructure attempt. This overlaps a host sleep/wake interval; the overlap
  does not prove causation. The fresh bounded retry and independent reconstruction both pass; the latter runs
  the 1,444-test application baseline and 13 task-specific tests. Power-event timestamps
  independently confirm a 42,144-second hibernation interval. Wall time
  spanning that interval is not a performance measurement.

- Final RSpec review exposed a false selected-file attribution: the old formatter
  recorded both the shared definition and including file as owners. A new regression
  fails with the old formatter (one assertion failure, no errors). Commit `c5172fd`
  records only the including owner; affected RSpec and distribution lanes are rerun.

- A final combined shell command completed core, package and workflow acceptance, then
  referred to a nonexistent `gemfiles/ai.gemfile`. Its overall exit is correctly retained
  as nonzero. The separate command using `ai_rails_8_1.gemfile` passes offline AI 8 / 60.
- Rails 7.1 prints the missing-generator diagnostic but exits zero. The former test
  asserted a newer Rails convention. Commit `017ac49` corrects that test only; its
  affected native workflow was rerun against the committed bytes in all three lanes.
  Other sweep results remain attributed to the original source commit, whose packaged
  resources, example code, recipes and benchmark inputs are unchanged.
- The first original-adoption replay timed out while contacting Elasticsearch. The
  disposable service subsequently reported healthy; a fresh complete replay passed
  both roots without changing limits or application code.
- The initial Next.js run omitted its workflow's `npm --prefix frontend ci` setup.
  Installing from the existing lock and repeating the full lane passed.
- The initial RAG evidence query exceeded the existing two-second statement timeout
  while multiple service lanes shared a two-CPU Docker engine. A fresh complete replay
  passed without relaxing that bound. Resource contention is plausible, not proven.
- The first advanced-composition attempt connected during PostgreSQL initialization
  shutdown. The diagnostic retry checked host-side SQL readiness before acceptance and passed.
  Commit `10d4d9b` fixes the underlying health check to use TCP; a fresh run of the
  unmodified documented startup/test sequence then passes 7 / 30.
- Initial native Le Mans commands lacked the workflow's `RUBYOPT=-EUTF-8` setting on
  this host. They failed before controls ran. Fresh commands use that declared setting;
  attempts to replay missing outputs remain separately recorded failures.
- Browser-control preparation inherited already-resolved images from its parent
  workspace. Rebuilding was correctly refused. Selecting the actual Fizzy task image
  and setting UTF-8 resolved the local setup mistakes; the final browser controls pass.

No upstream test, timeout, requirement or reference solution was weakened to obtain a
passing result. Dependency preparation is separate from offline application execution.
Native Le Mans may refresh its model registry on the host; candidate containers and
application providers are offline, and no coding-agent/model inference is authorized.

## Limits and pending gates

Local release decision: accepted for source candidate `10d4d9b` and the gem digest
recorded above. Both implementation changes are verified and archived. The release
change remains open exclusively for hosted CI; this evidence commit changes no shipped
resources, dependency locks, accepted debt or application behavior.

Local macOS/ARM64 and Docker results do not establish hosted Linux CI success. The
checkout has no remote; hosted CI remains open in `verify-1-0-release-candidate`.
No tagging, publication, deployment, live provider evaluation or agent study ran.
Historical evidence, original study conclusions, untracked research and accepted debt
are preserved. Raw logs remain in the local verification workspace; committed evidence
contains portable commands, outcomes and hashes, not workstation paths or raw contents.
