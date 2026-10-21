# Package-aware refactoring assessment — local evidence

The `respect-package-ownership-in-refactor-plans` change corrects selected-context source
ownership and supports explicitly configured upstream root packages. Implementation is
commit `4550ddbb3cae0b9df1b87ae8603fa3cc2a626372`; specification/evidence reconciliation
follows separately. The [resource manifest](package-refactor-hashes.json) records the
clean Git archive's gem digest, all 170 packaged resource hashes and 34 unchanged locks.

## Behavior verified

The initial six regressions produced two failures and two errors: nested malformed Ruby
made a parent incomplete, child model declarations supplied false parent evidence, and
both root fixtures failed path validation. After correction, all six pass. The broader
focused suite passes 53 tests and 323 assertions, including existing source/prompt checks.

One validated upstream discovery supplies context selection and package ownership for
each assessment. Selected non-hidden Ruby includes tests, lib and other existing locations;
independently discovered child packages are pruned before parsing and model collection.
Root contexts use their own installed intent and omit application-root dependency/generated
trees documented in the adoption guide. No source/prompt-check scope or public schema changes.

Safety acceptance covers duplicate/custom/nested roots, ambiguous selection, sidecar-free
children, missing discovery prerequisites, malformed/unsafe inventory, symlinks, non-regular
entries and failed directory/file reads. Sentinels reject application/source execution and
snapshots prove read-only behavior. Proposed profiles remain proposals. Three faulty controls
reintroduce child inclusion, app-only narrowing and child-model contamination; the behavioral
oracle rejects each. Reordered equivalent input passes.

Installed-gem fixtures exercise packs/ and components/ with nested and root packages,
successful findings and selected syntax failures. Gem provenance points to the temporary
installation, not the checkout. Snapshots preserve locks, configuration, workflow history,
instructions, skill files, receipts and accepted debt. The delivery journey additionally
replays reviewed upgrades for agents, claude and cursor under both package roots, including
the changed planning reference, retained custom adoption instructions, pending-review status,
explicit keep_local decisions and repeated generation. Real HTTP/browser verification,
fault controls, loading, assets and Packwerk run against disposable SQLite applications.

## Commands and results

Use managed Ruby 3.4.10 and Node 20.19.0 on PATH. No application or repository dependency
lock changed. Rails 7.1.6/8.1.3.1 and core Minitest 5.26.1/5.27.0 remain as before.

```sh
bundle exec ruby -Itest test/package_refactor_test.rb
bundle exec ruby -Itest -e 'Dir["test/{context_refactor,package_refactor*,package_source*,package_prompt*}_test.rb"].sort.each { |file| require_relative file }'
bundle exec rake test
BUNDLE_GEMFILE=gemfiles/rails_7_1.gemfile bundle exec rake test
bundle exec rake test:package
BUNDLE_GEMFILE=gemfiles/ai_rails_7_1.gemfile bundle exec rake test:ai
BUNDLE_GEMFILE=gemfiles/ai_rails_8_1.gemfile bundle exec rake test:ai
bundle exec rake test:workflows
TMPDIR=/private/tmp SE_OFFLINE=true SE_AVOID_STATS=true \
  SE_CHROMEDRIVER="$HOME/.cache/selenium/chromedriver/mac-arm64/155.0.8059.79/chromedriver" \
  BUNDLE_GEMFILE=test_delivery/bundle/Gemfile bundle exec rake test:delivery
bundle exec ruby -Itest test/distribution_integrity_test.rb
bundle exec rubocop --cache false
npm run contracts:validate
ruby script/validate_skills
bundle exec ruby script/validate_examples.rb
ruby script/privacy_check.rb
npm run spec:validate
```

| Lane | Actual result |
| --- | --- |
| Core Rails 7.1 and 8.1 | 261 tests / 2,640 assertions each; zero failures, errors or skips |
| Packaged acceptance | 12 tests / 908 assertions; zero failures, errors or skips |
| Optional offline AI, both Rails lanes | 8 tests / 60 assertions each; zero failures, errors or skips |
| Workflow acceptance, corrected environment | 3 tests / 39 assertions; zero failures, errors or skips |
| Installed delivery/guidance, both roots and all targets | 2 replays / 384 assertions; zero failures, errors or skips |
| Final archive contamination/installed links | 2 tests / 735 assertions; zero failures, errors or skips |
| RuboCop | 861 files clean |
| Contracts | 8 schemas / 73 actual cases; 10 tests / 142 assertions |
| Skills/catalog | 6 development skills, 8 product skills, 12 applications |
| Privacy | Zero findings |
| Strict OpenSpec before archive | 42 items passed |
| Strict OpenSpec after synchronization/archive | 41 items passed |
| Existing dependency locks | 34 byte-identical to starting revision 431b590 |

Full suites ran before final documentation reconciliation; the separate final archive/link
check verifies the reconciled installed documents. The clean committed archive build
matches the explicit resource inventory. It excludes this evidence and local research.

## Failed attempts and limitations

- The initial regressions intentionally failed before implementation.
- RuboCop found complexity, line-length and assertion-parentheses issues. A small predicate
  extraction and formatting corrected them without lint configuration changes.
- Workflow acceptance initially failed all three tests because Specify was absent from PATH.
  The previous temporary installation was unavailable. Restoring pinned Spec Kit v1.0.0
  (upstream commit `1ecccc04a0fd163c889ef034b909d4d3c49dc2b9`) into a disposable Python 3.13.3
  environment and adding it plus repository node_modules/.bin to PATH made the lane pass.
  No global tool or application dependency was upgraded. The temporary Python tool's
  transitive resolution is not claimed identical to earlier environments.
- Existing upstream packs commands print a Packwerk StringIO diagnostic during packaged
  acceptance. The existing isolated boundary invocation loads StringIO and passes; this
  change neither alters that upstream integration nor suppresses its output.
- Browser acceptance required local socket access. It used offline ChromeDriver, loopback
  Puma and disposable SQLite, without existing application data or external providers.

Static ownership and AST evidence do not prove Ruby constant resolution, adequate tests,
behavioral correctness or migration completion. Enumeration is not an atomic filesystem
snapshot or a defense against malicious concurrent file replacement. This is bounded
local acceptance, not a new full release-candidate/corpus replay or agent-effectiveness study.
Campfire's frozen native-test limitation, unfinished studies and hosted release CI remain open.
