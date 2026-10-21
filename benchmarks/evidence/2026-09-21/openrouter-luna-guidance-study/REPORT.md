# GPT-5.6 Luna study after guidance and protocol hardening

The separately authorized ten-attempt study completed at Foundry revision
`ce57b2657398ffca89715e3d28e82bc360829790`: **nine passed and one failed**.
Native Le Mans and fresh independent verification agree on all ten outcomes.
Provider-confirmed spend is **$0.12277142**, below the $7 stopping budget.
No retries, candidate repairs, substitutions or additional trials ran.

## Outcomes

Smoke is separate from benchmark aggregates. The Foundry comparison passed 6/6
(two tasks in each of Rails, packs and Foundry); upstream Rails passed 2/3.
There were ten attempted and protocol-valid trials, one behavioral failure,
zero invalid-protocol results, zero infrastructure errors, zero disagreements,
zero incomplete results and zero unstarted trials.

| Trial | Native / independent | Reported USD | Steps | Input + output tokens | Native duration, seconds |
| --- | --- | ---: | ---: | ---: | ---: |
| hello-world (smoke) | pass / pass | 0.00304494 | 6 | 21,025 | 64.1 |
| boundary-extraction-rails | pass / pass | 0.00720872 | 8 | 56,208 | 41.7 |
| boundary-extraction-packs | pass / pass | 0.01241098 | 13 | 148,737 | 79.6 |
| boundary-extraction-foundry | pass / pass | 0.01906127 | 19 | 317,338 | 104.1 |
| stale-embedding-rails | pass / pass | 0.00799540 | 10 | 55,979 | 56.8 |
| stale-embedding-packs | pass / pass | 0.00873477 | 10 | 69,136 | 65.1 |
| stale-embedding-foundry | pass / pass | 0.00902148 | 10 | 72,557 | 61.2 |
| ar-tenant-isolation | pass / pass | 0.01747303 | 12 | 186,747 | 127.5 |
| aj-enqueue-after-commit | pass / pass | 0.01161199 | 13 | 160,412 | 106.3 |
| ft-comment-reaction-live-echo | fail / fail | 0.02620884 | 20 | 479,261 | 219.8 |

Durations include native setup/grading, not the separate independent replay.
Token totals include repeated/cached input; individual usage fields and cost
sources are preserved in the [final machine report](reports/09-ft-comment-reaction-live-echo/report.json).
No time, step or cost limit was reached.

## Remaining failure

The unchanged upstream live-reaction task passed two browser checks and failed
four in both graders: three assertion failures and one missing-element error.
The live-delivery, author-echo and draft-preservation checks could not find the
expected remote reaction. The creator-deletion check could not find the visible
`.reaction__delete` control. The echo failure therefore does not prove that a
duplicate was observed; the draft check did not reach proof of draft loss.

The candidate source replaces the whole reactions strip, including its composer,
uses `Current.user` in shared reaction markup, and does not assign stable IDs to
individual entries. These are investigation leads, not independently isolated
causes. No repair was applied during this study.

The native and independent application baselines each passed 1,517 tests and
5,708 assertions with the two pinned Vips policy skips retained. Each browser run
completed six tests and 32 assertions, with three failures, one error and no skips.
Selenium emitted blocked external metadata/telemetry warnings, but the installed
browser ran and both graders reproduced the same failures.

Candidate patch SHA-256:
`0cba1a704df26b74a226492686c57e9c817fba73a4a2ae8d79112ea1cb952f78`.
See the original [native checks](results/09-ft-comment-reaction-live-echo/gpt-5.6-luna-medium/ft-comment-reaction-live-echo__Kj0UffP/checks.json),
[native log](results/09-ft-comment-reaction-live-echo/gpt-5.6-luna-medium/ft-comment-reaction-live-echo__Kj0UffP/verifier.log)
and [captured patch](results/09-ft-comment-reaction-live-echo/gpt-5.6-luna-medium/ft-comment-reaction-live-echo__Kj0UffP/agent.patch).

## Frozen conditions and interpretation

The model was `openrouter/openai/gpt-5.6-luna#medium`, using native Le Mans miniswen
with OpenAI routing and fallback disabled. Le Mans 1.3.5 remained pinned at
`2d0b7fb8d3b0077574dcf7b70fd4e32c8f9d6e76`; AI-evals remained pinned at
`5327efe54dd767d662ab89332f6a4285fef07bd8`. Preparation used managed Ruby 3.4.10
and new external workspaces. Resolved dependencies, image IDs, task/profile hashes,
installed-gem hashes and skill hashes are retained under `dependencies/` and in
[study.json](study.json). Manifest SHA-256:
`702f34d0353d370082d600711740421083cedce44f6a92bebf588e52290cafa1`.

One attempt per task ran serially, in the frozen order. Smoke had three minutes,
15 steps and $0.25; measured tasks had ten minutes, 50 steps and $0.75 each.
Each response was limited to 4,096 output tokens and shell commands to 60 seconds.
Application and fresh grading containers were network-disabled and credential-free.
Host-side provider requests used the existing dedicated key, with its separately
authorized $20 lifetime cap and no periodic reset; this study retained its $7 stop.

Preflight ran before each attempt and checked prior evidence, allowance, routing,
pricing and frozen inputs. The final provider usage increased from $0.29992145 to
$0.42269287, exactly matching summed native cost at eight decimal places.
The remaining key allowance was $19.57730713. Interim provider snapshots lagged;
preflight conservatively used the larger of provider delta and native reported cost.
The recorded price was $0.20/M input and $1.20/M output, with cache/tier details in
the sanitized snapshots. Native estimates cite RubyLLM's model registry; provider
usage independently confirms the total, not individual request allocation.

The [input comparison](input-comparison.json) shows all ten profile hashes unchanged
from the prior study. All six Foundry-suite task hashes changed: shared protected-file
guidance applies to every group, while Foundry also receives the revised product
guidance and gem. Smoke and upstream task hashes are unchanged. This is a study of
changed inputs, not an identical-input repetition or proof that guidance caused
the passes. One attempt per cell cannot establish future reliability or broad
productivity gains. Offline repaired candidates and reference solutions were not
supplied to these agents. Earlier paid scores and repair evidence remain unchanged.

## Evidence and validation

The [command sheet](COMMANDS.md) records all native execution commands.
Independent verification used `benchmarks/suite replay` for each saved result;
`study-report` wrote a new derived report after each attempt. Original results and
derived verification are separate. The [artifact inventory](artifact-inventory.json)
records 178 byte-for-byte archived artifacts with SHA-256 hashes and an exact-key
credential scan. The study inputs and contributor implementation passed their
final frozen-input validation. All 1,472 inventoried historical evidence, earlier
repair-fixture and product-skill files remained unchanged; see
[before](history-before.json) and [after](history-after.json).

Post-run repository checks are recorded below. This evidence-only change does not
alter product code, skills, task requirements or grading rules. Installed-gem and
offline controls were accepted in the preceding [implementation evidence](../repeatability-repairs/REPORT.md);
those larger lanes were not repeated for the report addition. Hosted release CI
still awaits a repository destination. This completed authorization permits no
further paid attempts.

| Command | Result |
| --- | --- |
| `bundle exec rake test` | 147 tests, 1,134 assertions; passed |
| `BUNDLE_GEMFILE=benchmarks/Gemfile bundle exec ruby -e 'Dir["benchmarks/test_lemans/*_test.rb"].sort.each { \|file\| require_relative file }'` | 64 tests, 542 assertions; passed |
| `bundle exec rubocop` | 705 files, no offenses |
| `ruby script/validate_skills` | Six development and eight product skills valid |
| `bundle exec ruby script/validate_examples.rb` | Twelve examples valid |
| `npm run contracts:validate` | Eight schemas, 73 cases; ten tests, 142 assertions passed |
| `npm run spec:validate` | 31 items passed, zero failed |
| Documentation whitespace and artifact/link validation | Passed; 178 archive hashes match and local report links resolve |

The full staged `git diff --cached --check` reported whitespace in captured patches
and logs, including the single-space context lines required by unified diff format.
Those original evidence bytes were retained. This is an explicit whitespace-check
exception for archived evidence, not a claim that the full staged check passed.

Two read-only reporting helpers initially encountered local setup mistakes: a
search named a nonexistent CI filename, and a JSON inspection omitted UTF-8.
They were corrected to the existing workflow path and `ruby -EUTF-8`; no trial,
grading result or archived artifact changed. These were not benchmark failures.
