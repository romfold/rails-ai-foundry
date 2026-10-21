# Package-aware source verification — local evidence

This record covers `cover-upstream-packages-in-source-checks`. The implementation
is development-time checking and installed guidance. Application execution, dependencies,
the twelve-example catalog and the eight-skill catalog are unchanged.

Source implementation commit: `19ec255`; the acceptance-driven byte-preservation fix
is `b27b8e1`. The [resource manifest](package-source-hashes.json)
records the final implementation commit, built-gem digest, 169 archive resource hashes and 34 unchanged
dependency lock hashes. The gem was built and inspected in a clean disposable Git archive.
This is bounded acceptance, not a new full release-candidate or twelve-application replay.

## Reproduction and implementation

Before the fix, a discovered `components/search` without foundry.yml could contain an
explicit Foundry dependency and still report success with zero inspected files. Two new
regressions failed on the prior implementation: missing package coverage and omitted
invalid Ruby. Both pass after separating upstream package discovery from optional intent.

The checker uses the existing package inventory, visits app Ruby files without evaluating
them and resolves intent against the deepest owning package. Unconfigured children do
not inherit a parent profile/namespace. Shell/root/custom/nested/overlapping layouts are
covered, including a package located exactly at another app root. Paths are normalized,
duplicates removed and symlink/read/discovery failures reject partial verification.

Offline controls deliberately omit unconfigured package sources, replace shell coverage
with package coverage and inherit a parent's domain profile. Each fails the relevant
acceptance assertion; valid selection and restored behavior pass. These controls do not
prove resistance to malicious Ruby or runtime constant resolution.

## Commands and environment

Use managed Ruby 3.4.10 and Node 20.19.0 on PATH. Existing locked Rails 7.1 and Rails 8.1
bundles are retained. Workflow checks additionally use the existing temporary Specify
1.0.0 installation and repository OpenSpec 1.12.0. No live application provider is used.

```sh
bundle exec rake test
BUNDLE_GEMFILE=gemfiles/rails_7_1.gemfile bundle exec rake test
bundle exec rake test:package
bundle exec ruby -Itest test_packaging/package_sources_test.rb
BUNDLE_GEMFILE=gemfiles/ai_rails_8_1.gemfile bundle exec rake test:ai
bundle exec rake test:workflows
bundle exec ruby -Itest test/distribution_integrity_test.rb
bundle exec rubocop --cache false
npm run contracts:validate
ruby script/validate_skills
bundle exec ruby script/validate_examples.rb
ruby script/privacy_check.rb
npm run spec:validate
```

The installed delivery replay uses its existing locked bundle, a preinstalled Chrome and
ChromeDriver, and loopback permission. `SE_OFFLINE=true` and `SE_AVOID_STATS=true` disable
Selenium Manager network resolution/telemetry; `SE_CHROMEDRIVER` selects the existing
155.0.8059.79 binary. These are local test prerequisites, not application dependency changes.

```sh
BUNDLE_GEMFILE=test_delivery/bundle/Gemfile SE_OFFLINE=true SE_AVOID_STATS=true \
  SE_CHROMEDRIVER="$HOME/.cache/selenium/chromedriver/mac-arm64/155.0.8059.79/chromedriver" \
  bundle exec rake test:delivery
```

## Verified results

| Lane | Actual result |
| --- | --- |
| Final core, both Rails lanes | 228 tests / 2,409 assertions each; no failures, errors or skips |
| Final focused source/rule/refactor/Rake tests, both Rails lanes | 36 tests / 185 assertions each; no failures, errors or skips |
| Upgrade and process recovery after byte-preservation fix, both Rails lanes | 29 tests / 159 assertions each; no failures, errors or skips |
| Packaged acceptance | 8 tests / 646 assertions; no failures, errors or skips |
| Final installed source coverage, both roots | 2 tests / 148 assertions; no failures, errors or skips |
| Final installed delivery, browser and reviewed-upgrade matrix | 2 replays / 372 assertions; no failures, errors or skips |
| Offline AI | 8 tests / 60 assertions; no failures, errors or skips |
| Workflow integration | 3 tests / 39 assertions; no failures, errors or skips |
| Final archive contamination and installed links | 2 tests / 715 assertions |
| Final RuboCop | 850 files clean |
| Contracts | 8 schemas / 73 actual cases; 10 tests / 142 assertions |
| Skills/catalog | 6 development skills, 8 product skills, 12 applications |
| Privacy | Zero findings |
| Strict OpenSpec before reconciliation | 42 items passed |
| Strict OpenSpec after synchronization and archive | 41 items passed |
| Existing dependency locks | All 34 byte-identical |

Installed source acceptance runs check, adopt and the source architecture task without
checkout code. Synthetic shell/package exceptions and an initializer that raises prove
that checks parse without executing application code or booting Rails. Package ownership,
file counts, diagnostic locations and configured-context absence are asserted. Consumer
locks, package configuration, workflow history and accepted debt remain unchanged.

The existing installed delivery replay passes for packs/ and components/, including all
six root/target combinations (agents, claude and cursor). Each performs assessment,
safe updates, explicit keep_local resolution and repeat generation, then executes the
installed HTTP/browser verification helper. The new native-conventions reference is
asserted present after upgrade. Custom instructions, receipts, selected workflows,
unrelated skills, package debt and locks retain their documented ownership. Existing
loading, assets, Packwerk, production independence and seven delivery fault categories
continue to pass within that replay.

## Failed attempts and corrections

The first delivery replay could not bind Selenium's loopback socket under sandboxing:
`EPERM`, with zero browser assertions. A standalone launch reproduced that infrastructure
failure. Repeating with loopback permission ran the HTTP/browser checks successfully but
failed later during the upgraded-reference exercise. A focused replay recorded an
Encoding::UndefinedConversionError when text-mode writes attempted to transcode decoded
snapshot bytes under Rails' UTF-8 internal encoding. The new unit regression additionally
exposed text-mode snapshot reads under an ASCII external encoding. The existing store
now reads snapshots and writes temporary replacements in binary mode. Upgrade/rollback
preserve Unicode bytes, and all 29 upgrade/recovery tests pass on both Rails lanes.
The complete installed matrix passes after this correction: 2 replays / 372 assertions.

Initial RuboCop findings required alignment, assertion parentheses and extracting a small
context lookup from source inspection. No lint settings changed. A final app-root edge
case was added after the first complete core runs (226 / 2,404 each); focused tests and
the next full runs passed (227 / 2,407 each). Full core replay after the byte-preservation
fix passed at 228 / 2,409 each. The earlier packaged/AI/workflow/contract evidence remains
attributed to the source implementation; the correction additionally reran full core,
upgrade/recovery, distribution and installed delivery/browser acceptance. No additional
application integration or release-candidate coverage is implied.

Campfire's frozen Rails/Minitest limitations, unfinished agent-study acceptance and the
hosted release gate remain open. No dependency upgrades, test-harness repair, application
provider calls, agent trials, deployment, publication or historical evidence rewrites ran.
