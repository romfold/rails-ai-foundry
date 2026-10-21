# Executable Rails feature verification

For Rails applications using Minitest or explicitly selected RSpec, the sibling `scripts/verify.rb` runs ordinary
Rails tests in fresh processes. It adds no application runtime or production dependency.
Run in a disposable test environment with the application's locked dependencies and
browser/services prepared. Tests retain their existing provider/network policy; this
helper does not sandbox application code or provision services.

From the application root, using the default skill target:

```sh
ruby .agents/skills/foundry-verify/scripts/verify.rb \
  --caller packs/billing/test/invoices_delivery_test.rb
```

For realtime or other JavaScript interaction, require system tests as well:

```sh
ruby .agents/skills/foundry-verify/scripts/verify.rb \
  --caller test/integration/messages_test.rb \
  --realtime --browser test/system/messages_test.rb
```

Use `.claude/skills` or `.cursor/skills` for those installed targets. `--app PATH`
selects an explicit application root. Package roots and test filenames are application
choices; the examples are not required paths. Repeat `--caller` and `--browser` to
select multiple files. Each must execute tests of the appropriate Rails type:
`ActionDispatch::IntegrationTest` and `ActionDispatch::SystemTestCase` respectively.

The baseline defaults to `bin/rails test`. Without package discovery, `--baseline PATH` replaces default discovery with the
explicit paths. Keep the baseline
representative of existing behavior, including existing HTTP callers; do not reduce it
to a few unrelated model tests to evade a failure. Files are preflighted before any
command runs. All phases set `RAILS_ENV=test`; migrate/prepare a disposable database
using the application's own workflow beforehand.

The helper requires structured Minitest results in addition to a successful command.
For Minitest it rejects no tests, no matching tests in a selected file, assertion-free selected checks,
failures, errors, selected-test skips and absent reports. A printed success summary
does not count. Baseline skips fail unless individually reviewed and listed with
`--allow-baseline-skip 'ClassName#test_name'`; accepted skips remain visible. There is
no selected-test skip exemption. Commands, test output, failures and phase totals are
printed directly; keep them in CI artifacts. Every invocation reruns verification;
no prior successful report is reused.

The baseline must contain at least one passing assertion. Individual legacy baseline
tests with no assertions do not establish feature coverage; selected caller/browser
tests must each assert behavior.

Each phase has a 600-second timeout. Set `--timeout SECONDS` explicitly when needed
(1–3600). On timeout or interruption the helper stops its process group, rejects
completion and leaves database/service cleanup to the disposable environment. This
helper supports POSIX hosts. External frontend runners and non-HTTP callers retain
their own equivalent required verification jobs.

## RSpec applications

Select `--framework=rspec` explicitly; the default remains `minitest`. Mixed applications
run separate required invocations. Keep compatible `rspec-rails` and `rspec-core` in the
application's locked test bundle. The helper never installs dependencies.

```sh
ruby .agents/skills/foundry-verify/scripts/verify.rb \
  --framework=rspec --caller spec/requests/tickets_spec.rb \
  --realtime --browser spec/system/ticket_review_spec.rb
```

RSpec defaults to its normal baseline discovery. Explicit `--baseline` paths select a
representative baseline as above. Caller files require `type: :request`; browser files
require `type: :system`, including shared examples attributed to the including file.
The formatter checks actual started/completed examples and suite outcomes. Missing,
malformed, empty, incomplete, failed, wrong-type or pending selected evidence fails.
Dry runs, active inclusion/exclusion filters, filtered conditional examples, excluded
file patterns and only-failures runs are refused; remove narrowing in the application's
reviewed test configuration rather than hiding it. Ordinary random ordering is supported.

For reviewed baseline pending examples, use their native RSpec ID, for example
`--allow-baseline-skip './spec/models/legacy_spec.rb[1:2]'`. Selected caller/browser
pending examples never pass. Failures outside examples also reject completion.

RSpec outcomes do not count expectations. Output says **expectation counts unavailable**;
a passing expectation-free example can pass this adapter. Review assertions and run
known-fault controls. The helper does not instrument matchers or turn example counts into
Minitest assertion counts. Native metadata alone does not prove browser interaction.

## Make verification required

Add the chosen invocation as a step in the application's existing CI configuration,
and require that CI job for merging. For a Rails `config/ci.rb` workflow, for example:

```ruby
step 'Feature behavior',
     'ruby .agents/skills/foundry-verify/scripts/verify.rb ' \
     '--caller test/integration/messages_test.rb ' \
     '--realtime --browser test/system/messages_test.rb'
```

Preserve existing CI jobs and tests. Do not catch/ignore the helper's failure or apply
`continue-on-error`. Keep test selections and the helper in the reviewed checkout.
For current eight-skill catalogs, use `foundry:skills --upgrade` to assess updates and
follow the installed gem’s docs/skill-upgrades.md for explicit application and review.
Historical catalogs retain disposable comparison and manual reconciliation. Repeat
generation never overwrites guidance. After updating this helper, rerun selected tests
and known-fault controls; file installation is not behavioral acceptance.

## Evidence limits

A pass establishes execution of the selected tests, not completeness of their
assertions. Review coverage of actual actors, authorization and visible behavior.
SystemTestCase inheritance alone does not establish a JavaScript-capable driver or
connected subscriptions: configure the browser and prove the interactions in those
tests. Use the behavioral reference for multi-viewer assertions and negative controls.
The helper is not an adversarial grader: trusted tests/CI are necessary to reject
deliberately modified reporting or assertions. An agent that ignores the command can
still submit a patch, but a required CI job can reject it. Do not turn a successful
local check into an agent score or a claim that future trials will all pass.

RSpec custom file patterns and active exclusion/inclusion filters are refused conservatively. Use explicit baseline paths for custom test roots; the helper does not silently override `.rspec` or application settings.

## Include the complete non-system package baseline

Opt in with `--include-pack-tests` for either framework. This combines conventional
root tests, tests in packages discovered by locked `packs-specification`, and explicit
`--baseline` additions. It supports custom/nested roots and ordinary packages without
Foundry sidecars. The inventory prints origins, deferred browser files and packages
without tests. Files are canonicalized and deduplicated; missing planned loaded-file
evidence fails even if other tests pass. Loading is separate from test ownership.

Automatic scans exclude system, fixtures, dummy, support and node_modules directories.
Browser files remain explicit through `--realtime --browser`; system baseline additions
are rejected. Unsupported custom discovery/filter environment settings fail rather than
silently reducing coverage. Existing invocations without the option retain their behavior.

Copy and adapt the installed gem's `docs/package-aware-verification.md` into an
application-owned `bin/verify-feature` command. Preserve existing commands; fix the
reviewed target/framework/caller/browser selections and require both invocations for a
mixed application. Prepare databases/browser separately, propagate failures and keep
Packwerk checks separate. No saved manifest, cache or automatic feature selection exists.

For AI artifacts, `foundry check --prompts` covers every upstream package prompt root, including packages without foundry.yml. Use the actual deepest package as contract owner; apply namespace intent only from that owner’s explicit configuration. Missing contracts and unsafe artifacts fail; zero contracts is not AI acceptance. Review newly exposed findings explicitly, preserve prompt/agent receipts, and run authorization, provider-failure and evaluation tests separately with offline inputs.
