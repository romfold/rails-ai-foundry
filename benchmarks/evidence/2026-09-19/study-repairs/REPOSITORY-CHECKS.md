# Repository acceptance

Managed Ruby 3.4.10 and Node 20.19.0. All tests were offline; no coding agent or provider was called.

| Command | Result |
| --- | --- |
| `bundle exec rake test` | 147 tests, 1,133 assertions, pass |
| `bundle exec rake test:package` | 6 tests, 416 assertions, pass |
| `bundle exec rake test:workflows` with pinned Specify/OpenSpec on PATH | 3 tests, 39 assertions, pass |
| `BUNDLE_GEMFILE=gemfiles/ai_rails_8_1.gemfile bundle exec rake test:ai` | 8 tests, 60 assertions, pass |
| `BUNDLE_GEMFILE=benchmarks/Gemfile bundle exec ruby -EUTF-8 -Ibenchmarks/test_lemans -e 'Dir["benchmarks/test_lemans/*_test.rb"].sort.each { \|file\| require_relative file }'` | 55 tests, 284 assertions, pass |
| `bundle exec rubocop --cache false` | 699 files, no offenses |
| `ruby script/validate_skills` | 6 upstream development skills and 8 product skills valid |
| `bundle exec ruby script/validate_examples.rb` | 12 catalog applications valid |
| `npm run contracts:validate` | 8 schema assets and 73 actual cases; 10 tests, 142 assertions, pass |
| `npm run spec:validate` | 32 items passed before archive; 31 passed after archive |

The installed-gem tutorial runs with both `packs/` and `components/`, verifies exact
context discovery, rejects the misplaced sidecar without writes, retains an accepted-debt
fixture, preserves customized skill/reference bytes and receipt, and retains workflow `none`.
Its intentionally faulty endpoint still fails behavior despite passing architecture checks.

Development failures were corrected without weakening checks: the initial workflow command
omitted the already-installed Specify CLI from PATH; the initial AI command used the core
bundle without WebMock; an initial direct packaging invocation omitted `bundle exec`.
A new CLI unit test initially omitted the consuming application's marker files. Formatting
issues found by RuboCop were fixed. The final commands above passed.

The derived realtime application's own `bundle exec rubocop --cache false
app/models/reaction.rb app/controllers/cards/reactions_controller.rb` also passed (2 files).
