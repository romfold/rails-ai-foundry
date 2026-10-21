# Package-aware prompt verification — local evidence

This record covers `cover-upstream-packages-in-prompt-checks`. It extends opt-in
development-time prompt checking using upstream package topology. Application execution,
agent scaffolding prerequisites, prompt schema 1, CLI options and report fields remain
unchanged. No dependency versions, catalog applications or product skills are added.

Implementation commit: `acb3cd1`. The [resource manifest](package-prompt-hashes.json)
records that full commit, the clean Git archive's built-gem digest, 170 packaged resource
hashes and all 34 unchanged dependency locks. The archive exactly matches the explicit
packaging inventory. Evidence/specification reconciliation follows in a separate commit.

## Reproduction and implementation

The two initial CLI regressions used actual upstream discovery. Unconfigured package
instructions without a contract returned success, and a nested package contract could
claim shell ownership. Both expectations failed before the change (2 tests / 4 assertions).

Prompt checks now inspect shell and every discovered package app/prompts root independently
of foundry.yml. Shared private traversal determines the deepest owning package, normalizes
paths and avoids duplicate roots. Context configuration restricts only its owner's agent
namespace; unconfigured children inherit no intent. Explicit contracts and conventional
instruction files retain their recognition rules. References cannot cross into nested packs.

Unsafe discovery, directory inspection and selected-file failures stop checking. Contract
validation errors retain prompt.contract diagnostics; enumeration errors use the command
error channel before report publication. Templates and evaluation bodies are not interpreted,
constants are not resolved, and no model provider is contacted. Local path checks do not
guarantee protection against hostile concurrent filesystem replacement.

Offline faulty controls deliberately omit packages, inherit a parent namespace, accept
incorrect parent ownership and ignore missing artifacts. Acceptance rejects all four;
restored valid behavior passes. Static checking does not establish application authorization,
prompt-injection resistance, evaluation quality or adequate behavioral coverage.

## Commands and environment

All commands use managed Ruby 3.4.10 and Node 20.19.0 on PATH. Core Rails 7.1 and 8.1
bundles, optional AI bundles and every existing lockfile remain frozen. Workflow acceptance
uses the existing Specify 1.0.0 installation and repository OpenSpec 1.12.0.

```sh
bundle exec rake test
BUNDLE_GEMFILE=gemfiles/rails_7_1.gemfile bundle exec rake test
bundle exec rake test:package
bundle exec ruby -Itest test_packaging/package_prompts_test.rb
BUNDLE_GEMFILE=gemfiles/ai_rails_7_1.gemfile bundle exec rake test:ai
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

Installed AI journey acceptance uses an isolated, disposable PostgreSQL container and
the existing offline ChromeDriver. Loopback permission is required. No existing application
database is used. The local-only demo password is not a provider or production credential.

```sh
docker run --detach --rm --name foundry-prompt-acceptance-20261015 \
  --publish 127.0.0.1:55546:5432 --env POSTGRES_PASSWORD=foundry postgres:17.11
TMPDIR=/private/tmp PGPORT=55546 SE_OFFLINE=true SE_AVOID_STATS=true \
  SE_CHROMEDRIVER="$HOME/.cache/selenium/chromedriver/mac-arm64/155.0.8059.79/chromedriver" \
  bundle exec rake test:journey
docker stop foundry-prompt-acceptance-20261015
```

## Results

| Lane | Actual result |
| --- | --- |
| Final core, Rails 7.1.6 and 8.1.3.1 | 248 tests / 2,553 assertions each; no failures, errors or skips |
| Final packaged acceptance | 10 tests / 792 assertions; no failures, errors or skips |
| Offline AI, both Rails lanes | 8 tests / 60 assertions each; no failures, errors or skips |
| Workflow integration | 3 tests / 39 assertions; no failures, errors or skips |
| Installed AI journey and reviewed upgrades | 2 replays / 466 assertions; no failures, errors or skips |
| RuboCop | 857 files clean |
| Final archive contamination and installed links | 2 tests / 725 assertions |
| Contracts | 8 schemas / 73 actual cases; 10 tests / 142 assertions |
| Skills/catalog | 6 development skills, 8 product skills, 12 applications |
| Privacy | Zero findings |
| Strict OpenSpec before reconciliation | 42 items passed |
| Strict OpenSpec after synchronization and archive | 41 items passed |
| Existing dependency locks | All 34 byte-identical |

The core suites include archive contamination and installed-link validation, source
selection and fault controls, and skill-upgrade process recovery. Core Minitest remains
5.26.1 on Rails 7.1 and 5.27.0 on Rails 8.1; optional AI bundles retain RubyLLM 1.16.0.
No application harness or compatibility floor changed.

Installed prompt fixtures require no RubyLLM runtime. They verify three contracts across
shell, unconfigured parent and nested packages, reject missing contracts and incorrect
ownership, then confirm repaired behavior. Initializers raise if loaded. Application locks,
configuration, workflow history, receipts and accepted debt are compared byte-for-byte.

The installed AI journey covers packs/ and components/ with agents, claude and cursor.
Each target receives a safe AI-reference update alongside a customized verification skill
requiring an explicit keep_local decision. Assessment, pretend, apply, resolution, repeat
generation, rollback and a successive upgrade are exercised. Passing and deliberately
failing HTTP/browser fixtures verify the upgraded helper. Native ticket approval, queue
recovery, faulty controls and production loading remain separate behavioral evidence.

## Failed attempts and corrections

- Initial regressions confirmed the two coverage/ownership gaps before implementation.
- The old symlink test expected JSON after discovery; safe enumeration now fails earlier.
  Its assertion now requires nonzero status, no partial report and the affected location.
- Two test doubles initially invoked a callable or yielded an empty argument inadvertently;
  returning the intended test object/list explicitly corrected these controls.
- A source ownership fault double also changed discovery after private traversal was shared.
  The first complete core runs failed at that one control (245 / 2,527 each). Freezing the
  selected paths isolates its intended namespace fault. Subsequent runs passed at 247 / 2,537
  each before adding the final malformed-discovery regression.
- That regression exposed an uncaught JSON parse error at the existing upstream discovery
  handoff. Validate/normalize the returned inventory and translate invalid JSON into a
  controlled configuration error; no root-only fallback or new discovery mechanism is used.
- RuboCop required formatting and a small artifact-inspection method extraction. No lint
  settings or dependency versions changed. Docker inspection initially lacked sandbox socket
  access; the isolated service and acceptance ran with explicit local tool approval.

Historical research and trials remain untouched. Campfire's frozen native-test limitations,
unfinished study acceptance and hosted release CI stay open. This is bounded local acceptance,
not a new complete release-candidate replay, model-quality evaluation or productivity result.
