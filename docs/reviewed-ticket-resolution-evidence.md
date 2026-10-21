# Reviewed ticket resolution acceptance — September 22, 2026

Scope: the existing `rails-native-agent-tools-structured-output-rubyllm` application and reusable
installed guidance. Historical coding-agent trials and unfinished study acceptance are unchanged.
Application implementation: commit `cb90b5f` (the independent example and CI acceptance).
This is local behavioral evidence, not a productivity or live-model quality claim.

## Environment

macOS ARM64 host, managed Ruby 3.4.10, Rails 8.1.3.1, RubyLLM 1.16.0, RubyLLM Schema 0.4.0,
Solid Queue 1.7.0, Turbo Rails 2.0.23, Puma 7.2.1, Capybara 3.40.0 and Selenium WebDriver 4.49.0.
Chrome 153.0.8010.54 / ChromeDriver 153.0.8010.52. The example lockfile records exact transitive
versions and checksums. Core Ruby >= 3.3 and railties >= 7.1 floors are unchanged.

Disposable `foundry-reviewed-tickets` PostgreSQL 17.11 (Debian 17.11-1.pgdg12+2), ARM64,
served only on `127.0.0.1:55544`, with a 1 GiB tmpfs data directory. Tests use
`foundry_assistance_test`; no deployment DATABASE_URL or provider credentials are used.

## Commands and outcomes

Run from the example unless stated otherwise:

```sh
PATH=$HOME/.asdf/installs/ruby/3.4.10/bin:$PATH PGPORT=55544 RAILS_ENV=test bin/rails db:prepare
PATH=$HOME/.asdf/installs/ruby/3.4.10/bin:$PATH PGPORT=55544 SE_CHROMEDRIVER=$HOME/.cache/selenium/chromedriver/mac-arm64/153.0.8010.52/chromedriver bin/verify
PATH=$HOME/.asdf/installs/ruby/3.4.10/bin:$PATH RUBOCOP_CACHE_ROOT=/private/tmp/foundry-rubocop bundle exec rubocop
```

- Baseline: **37 tests / 132 assertions**, no failures/errors/skips.
- Explicit HTTP caller: **3 / 12**; browser review: **3 / 23**. Both execute through the shipped
  verification helper; browser tests run JavaScript in actual headless Chrome.
- Process recovery includes SIGKILL after provider completion, before local commit and after commit
  before acknowledgment. Native Solid Queue starts in a separate process and drains rediscovered work.
- Competing editor approvals yield one approval and one conflict; cancellation/execution preserves
  one committed outcome. Tests also cover both deterministic cancellation orderings.
- Controls: direct and delegated implementations each pass **15 / 45**; all four deliberate faults
  fail the expected assertion with **zero harness errors**. Approval bypass closes an unapproved
  ticket, revision bypass completes stale work, stale-owner acceptance persists old output, and
  duplicate execution advances the ticket revision twice. No candidate agent is invoked.
- PostgreSQL uniqueness/rollback, source and identity changes, rejection, retry history, bounded
  discovery, invalid structured output, authorized self-approval and immutable proposals pass.
- Source check: 26 Ruby files, two prompt contracts; Packwerk validates and checks without offenses
  or stale debt. Production eager loading runs without a Foundry execution runtime.
- Example Spec Kit prerequisites pass against its own `specs/001-reference` artifacts.

Repository checks (managed Ruby and Node 20.19.0 on PATH):

```sh
bundle exec rake test
bundle exec rake test:package
BUNDLE_GEMFILE=gemfiles/ai_rails_8_1.gemfile bundle exec rake test:ai
PATH=/private/tmp/foundry-spec-kit-lemans-20260918/bin:$PWD/node_modules/.bin:$PATH bundle exec rake test:workflows
RUBOCOP_CACHE_ROOT=/private/tmp/foundry-rubocop bundle exec rubocop
ruby script/validate_skills
ruby script/validate_examples.rb
npm run contracts:validate
npm run spec:validate
```

- Core: **166 / 1250**. Installed-gem acceptance: **6 / 486**, including `packs/` and `components/`
  consumers, selected workflow preservation, custom approval/recovery guidance, unchanged receipts
  and accepted debt. Intentional boundary and caller faults in that suite are expected failures.
- Optional AI: **8 / 60**, provider blocked. Real Specify CLI 1.0.0 / OpenSpec 1.12.0 initialization:
  **3 / 39**, covering the existing agent integrations without running coding agents.
- Contract validation: eight schema assets / 73 configuration-report cases; contract tests **10 / 142**.
- Six development skills, eight product skills and twelve catalog applications validate. The three
  modified skill entrypoints also pass the skill-creator validator using the existing Spec Kit Python
  environment. Root RuboCop checks 754 Ruby files without offenses.

## Failures observed and corrected

The initial additive migration used unprefixed ticket/user names; PostgreSQL rolled it back and
foreign keys were corrected to the existing Assistance tables. Browser preparation exposed that
our socket guard also intercepted local server binds; outbound connections remain loopback-only.
A missing favicon caused Rails' strict test exception handling to fail browser requests; the layout
now uses an inline empty icon.

Browser testing found a real terminal-polling defect: Turbo preserves outer frame attributes.
The changing terminal flag now lives inside refreshed content, and revoked sessions render a clear
terminal frame. Chrome 153 also intermittently reports detached nodes as a specific inspector
UnknownError during replacement. A test-only adapter translates only that exact message into
Selenium's stale-element error, preserving Capybara refind behavior; other browser errors propagate.

The first fault-control adapter failed through invalid Ruby `super` forwarding. Its harness was
corrected; controls are accepted only on behavioral assertion failure, never on exceptions.
Core acceptance caught the missing new resource in the explicit skill installation list and its
old file-count assertion. Both were corrected; custom skill files and receipts remain protected.
The default Python lacked PyYAML; the existing pinned Spec Kit Python environment validated skills.
Style/cache and invocation-directory errors were corrected and rerun; failed attempts were not
reported as successful evidence.

## Limits

Demo authentication, local effects only, no live providers, no additional agent trials, no paid
study, no deployment or publication. Model invocation may replay after a crash. Tests do not prove
an external side effect is exactly-once. Browser polling is bounded to six minutes per visit.
Append-only audit behavior is an application contract; database administrators retain SQL authority.
Linux/other Ruby compatibility remains in the existing hosted CI matrix, whose execution awaits a
repository destination. Historical evidence and unfinished study acceptance remain open as before.
