# Package-aware everyday verification

Use the installed `foundry-verify` skill to review the behavior to prove, then copy and
adapt a command owned by the application. Preserve any existing verification script.
This guide adds no application installer, task runner or automatic feature-test selector.

## Prepare and inspect

Install the application's locked bundle, including `packs-specification`, and prepare
its disposable test databases and browser driver using its existing setup instructions.
The helper neither installs dependencies nor provisions services. Keep provider calls
offline unless a separately authorized evaluation explicitly enables them.

```sh
ruby .agents/skills/foundry-verify/scripts/verify.rb \
  --include-pack-tests --caller packs/billing/test/invoices_delivery_test.rb
```

Select `.claude/skills` or `.cursor/skills` when appropriate. The opt-in discovers
packages using the locked upstream `Packs.all`, including custom/nested roots and
packages with no `foundry.yml`. It does not derive topology from directory names.
The baseline is the sorted, canonical union of root and package `test/**/*_test.rb`
(or `spec/**/*_spec.rb` with `--framework=rspec`) and explicit `--baseline` additions.
Root packages and overlapping discovery do not duplicate arguments. Package-only
applications are supported; packages without matching tests are reported without
claiming they were verified.

Automatic discovery excludes `system`, `fixtures`, `dummy`, `support` and
`node_modules` directories. System files are listed separately as deferred browser
checks; fixtures/dummy/support trees are not inspected for browser work. Select
browser files explicitly with `--realtime --browser FILE`. Explicit browser files
are excluded from the baseline even outside conventional system directories.
Additional baseline selections cannot include system paths. Custom browser placement
must be selected explicitly; filenames alone cannot establish Rails test type.

The printed inventory distinguishes root, package and explicit additions. A file
already discovered automatically retains its root/package label. Non-system support
files deliberately selected as extra baselines can load without owning tests; at least
one successful baseline test/example is still required. Loaded-file evidence rejects
silent omission of any planned baseline file. This evidence is separate from execution
ownership: loading shared examples does not credit the definition file for the including
file's examples. Loading alone proves neither useful assertions nor complete coverage.

Unsafe escapes, symbolic directory aliases, ambiguous ownership, malformed package
configuration and unavailable discovery dependencies fail before tests execute.
Custom `DEFAULT_TEST`, `DEFAULT_TEST_EXCLUDE`, `TESTOPTS` and `SPEC_OPTS` settings are
unsupported in this mode. Remove them after review or use the existing explicit
workflow. RSpec active filters, custom patterns and dry runs are refused before example
execution, after native suite loading. Foundry does not silently override them.
Without `--include-pack-tests`, framework discovery and explicit-baseline replacement
semantics remain unchanged. Mixed-framework applications need separate invocations.

## Own a repeatable command

Example `bin/verify-feature` for a Minitest application (adapt paths and reviewed skips):

```ruby
#!/usr/bin/env ruby
require 'rbconfig'
Dir.chdir(File.expand_path('..', __dir__))
exec RbConfig.ruby, '.agents/skills/foundry-verify/scripts/verify.rb',
     '--include-pack-tests', '--caller', 'packs/billing/test/invoices_delivery_test.rb',
     '--realtime', '--browser', 'test/system/invoice_review_test.rb'
```

For a single-framework RSpec app, add `--framework=rspec` and select request/system
specifications instead. For mixed applications, require both invocations sequentially:

```ruby
#!/usr/bin/env ruby
require 'rbconfig'
Dir.chdir(File.expand_path('..', __dir__))
helper = '.agents/skills/foundry-verify/scripts/verify.rb'
abort 'Minitest verification failed' unless system(RbConfig.ruby, helper,
  '--include-pack-tests', '--caller', 'packs/billing/test/invoices_delivery_test.rb',
  '--realtime', '--browser', 'test/system/invoice_review_test.rb')
exec RbConfig.ruby, helper, '--include-pack-tests', '--framework=rspec',
     '--caller', 'packs/billing/spec/requests/invoices_spec.rb',
     '--realtime', '--browser', 'spec/system/invoice_review_spec.rb'
```

Run `ruby bin/verify-feature`, or make the reviewed file executable for `bin/verify-feature`.
Do not rescue failures, ignore statuses or select only changed files. Fix the skill target,
framework and feature-specific caller/browser paths in review. Use repeated options for
multiple files; add `--allow-baseline-skip` only for individually reviewed native test IDs.
Selected caller/browser tests cannot be skipped. Remove browser flags only when the
feature has no browser requirement. Existing timeouts and process-group cleanup apply.
RSpec reports native example outcomes; expectation counts remain unavailable, and an
expectation-free example can pass. Review coverage and use deliberately broken controls.

Run architecture checks separately, for example `bundle exec foundry check --sources`
and `RAILS_ENV=test bundle exec foundry check --boundaries` in the isolated application.
Preserve accepted debt. This helper does not replace Packwerk or prove package privacy.

## Update and verify the installed helper

Use [reviewed skill upgrades](skill-upgrades.md): assess, inspect the review digest,
apply it, explicitly resolve customized files, and repeat generation. Upgrade every
helper dependency together. Keep local changes and recovery artifacts outside the gem.
An instruction upgrade does not upgrade application behavior or enforce CI. Run the
application command against working behavior and intentional faults after upgrading;
then call that same command from the application's existing required verification job.
No hosted execution is implied by local acceptance.
