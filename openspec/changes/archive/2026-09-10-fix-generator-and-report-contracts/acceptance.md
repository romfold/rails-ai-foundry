# Generator and report contract acceptance — 2026-09-10

The three reproduced defects are fixed without changing version 1.0.0, configuration/report schema numbers, dependency locks or accepted debt. Runtime namespace configuration is owned by the application; no Foundry production loader was added. Stable contracts document basename override scope and explicit repair of previously generated acronym contexts.

## Verified commands and results

Managed commands use Ruby 3.4.10 and Node 20.19.0 from their asdf installation bin directories. The floor core lane uses Ruby 3.3.10 and its own locked bundle.

| Command | Result |
| --- | --- |
| `bundle exec rake test` | 125 tests, 983 assertions, no failures/errors/skips |
| `BUNDLE_GEMFILE=gemfiles/rails_7_1.gemfile bundle exec rake test` (Ruby 3.3.10) | 125 tests, 983 assertions, no failures/errors/skips |
| `BUNDLE_GEMFILE=gemfiles/ai_rails_8_1.gemfile bundle exec rake test:ai` | 7 tests, 59 assertions, all pass, providers blocked |
| `GEM_PATH="/private/tmp/foundry-contract-fixes-gems:$HOME/.asdf/installs/ruby/3.4.10/lib/ruby/gems/3.4.0" BUNDLE_GEMFILE=gemfiles/ai_rails_7_1.gemfile bundle exec rake test:ai` | 7 tests, 59 assertions, all pass, providers blocked |
| `LC_ALL=C BUNDLE_VERSION=2.6.9 bundle _2.6.9_ exec rake test:package` | 4 tests, 222 assertions, all pass |
| `LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 BUNDLE_VERSION=2.6.9 bundle _2.6.9_ exec ruby -Itest -Ilib test_packaging/native_boundary_test.rb` | 1 test, 72 assertions, all pass |
| `bundle exec ruby -Itest -Ilib test/namespace_inflections_test.rb` (final focused rerun) | 8 tests, 38 assertions, all pass |
| `bundle exec rubocop --cache false` | 466 files, no offenses |
| `ruby script/validate_skills` | Six upstream and eight product skills valid |
| `bundle exec ruby script/validate_examples.rb` | Twelve executable examples valid |
| `npm run contracts:validate` | 8 tests, 119 assertions; eight schema assets and 67 cases valid |
| `npm run spec:validate` (before archive) | 26 specifications/changes valid with strict checking |
| `npm run spec:validate` (after synchronization and archive) | 25 items valid; only the separate release candidate remains active, with 3 of 4 tasks complete |
| `git diff --check` | Pass |

Core regressions exercise successful and unsuccessful captures with valid Unicode tagged US-ASCII and invalid UTF-8 bytes, preserving command outcomes. Installed acceptance executes real Packwerk and audit under C and UTF-8 locales and preserves accepted debt. Fresh-process Rails eager loading covers API, APIClient, GraphQL and nested namespaces; installed production acceptance excludes Foundry. Ownership regressions cover both generation orders, previews, customized repeats, partial and unsafe paths, conflicting mappings and rollback with unchanged filesystem snapshots.

The Rails 7.1 AI lane initially lacked activejob, activemodel and activerecord 7.1.6 in the managed Ruby 3.4 gem directory. Exact cached gems from the Ruby 3.3 installation were installed offline into `/private/tmp/foundry-contract-fixes-gems`; no dependency lock was changed. Initial installed C-locale acceptance exposed the test harness tagging valid UTF-8 CLI JSON as US-ASCII. The harness now explicitly decodes the CLI's UTF-8 contract without scrubbing invalid bytes; the full packaged lane then passed. An initial production fixture assertion was narrowed to permit Bundler's path-gem version metadata; installed production acceptance still requires Foundry to be absent.

## Unavailable lane and retained gates

`bundle exec rake test:workflows` ran with the pinned local OpenSpec CLI on PATH and returned 3 tests, 6 assertions, 3 prerequisite failures: Spec Kit's `specify` executable is unavailable. Workflow integration was not verified in this run. Historical workflow evidence is not presented as a new passing result. Full logs were retained during execution at `/private/tmp/foundry-contract-fixes-workflows.log`, `/private/tmp/foundry-contract-fixes-package-c-retry.log` and `/private/tmp/foundry-contract-fixes-boundary-utf8.log`.

The twelve-app catalog was validated; independent service acceptance was not rerun for this fix. No live provider, hosted CI, publication or broader research feature is claimed. `verify-1-0-release-candidate` remains active with its hosted CI task pending. Unrelated `.cursor/` files are excluded.

All four added requirements and the modified ownership requirement match their synchronized baseline blocks exactly. Every pre-existing requirement and scenario was checked for preservation before archiving.
