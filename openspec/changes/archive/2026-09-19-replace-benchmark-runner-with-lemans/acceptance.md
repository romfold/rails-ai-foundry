# Verified acceptance — 2026-09-19

The implementation replaces contributor execution with pinned Le Mans and preserves
Foundry's product scope. Full evidence is in
[the upstream report](../../../../benchmarks/evidence/2026-09-19/lemans-upstream-controls/REPORT.md)
and [Foundry parity report](../../../../benchmarks/evidence/2026-09-18/lemans-foundry-controls/REPORT.md).

## Control gates

- Native Le Mans and fresh verification agree for all 42 upstream tasks: 42 references
  pass, 42 no-op candidates fail. Atomic (21), feature (20) and smoke (1) remain separate.
- All 45 Foundry controls retain expected behavior: 24 valid implementations and 21
  faults, including delegated/relocated implementations and delivery regressions.
- The selected set is complete, unique and free of unresolved disagreements or
  infrastructure errors. All 91 native attempts and 103 independent reconstruction
  attempts remain recorded, including failed setup, timeouts, interruption and corrections.
- Isolation probes cover Foundry, Writebook, Fizzy and SaaS. Fresh containers have no
  credentials, external network, capabilities or Docker socket; trusted grading files
  are read-only. All 345 historical pilot files remain byte-identical.
- Source integrity verifies all 190 exported upstream files. Dependency receipts record
  resolved gems/locks/image IDs; local overrides are explicit. No assertions were weakened.

## Commands and results

Commands use managed Ruby 3.4.10 and Node 20.19.0. Full Le Mans commands and external
raw-artifact paths are preserved in the evidence ledgers; all runs use oracle/nop,
not coding agents. No provider inference or new pilot ran.

| Command | Observed result |
| --- | --- |
| `BUNDLE_GEMFILE=benchmarks/Gemfile bundle exec ruby -e 'Dir["benchmarks/test_lemans/*_test.rb"].sort.each { |file| require_relative file }'` | 33 tests, 218 assertions, passing |
| `BENCHMARK_WORKSPACE=... BENCHMARK_EVIDENCE=... BUNDLE_GEMFILE=benchmarks/Gemfile bundle exec ruby benchmarks/acceptance/integrity_test.rb` | 7 process tests, 21 assertions, passing |
| `benchmarks/suite report ...` | 84/84 upstream controls accepted; 45/45 Foundry controls accepted |
| `bundle exec rake test` | 143 tests, 1,108 assertions, passing |
| `bundle exec rake test:package` | 6 tests, 398 assertions, passing |
| `BUNDLE_GEMFILE=gemfiles/ai_rails_8_1.gemfile bundle exec rake test:ai` | 8 tests, 60 assertions, passing |
| `bundle exec rake test:workflows` with pinned upstream CLIs on PATH | 3 tests, 39 assertions, passing |
| `bundle exec rubocop` | 684 files, no offenses after retirement |
| `ruby script/validate_skills` | Six development and eight product skills valid |
| `npm run contracts:validate` | 10 tests, 142 assertions; eight schema assets and 73 cases valid |
| `npm run spec:validate` | Strict validation passes; repeated after archive |
| Workflow YAML parse | Independent Foundry/upstream jobs and failure uploads present |
| `git diff --check` | Passing |

An initial optional-AI invocation used the core bundle and failed on missing `webmock`.
The documented optional AI bundle passed; no dependency was added to core. Early contributor
commands in the detached checkout selected system Ruby; rerunning with managed Ruby passed.
Other integration corrections and exact original outcomes are detailed in the upstream report.

## Retirement and limits

The custom scheduler, installers, authentication, event parsing, old execution commands,
Python runner tests, agent Dockerfile and old CI lane are removed. The replacement CI has
one Foundry job and five upstream shards, with unconditional outcome uploads. YAML and local
commands are verified; hosted execution still awaits a repository destination.

The historical runner is inspectable at `d6fa504d0140888c02010988e6127ed7fd3e2769`;
the original Cursor experiment remains attributed to `fde15a8a36c15fe648f31b5aa56f002d6883232b`.
No compatibility wrapper exists. Production dependencies, CLI/schema contracts, generated
applications, eight product skills and twelve catalog applications are unchanged.
Publication, deployment and live experiments remain outside this change.
