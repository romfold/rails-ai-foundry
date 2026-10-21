# Native contexts and specification workflows

Optional AI generation is described in [native AI conventions](native-ai.md).

Foundry 1.0 provides development-time conventions and native upstream execution. The twelve delivered applications and future capability recipes are tracked in the [implementation program](implementation-program.md).

## Consumer setup

The gem is currently unpublished; build and install the local gem before using `foundry new` so the generated bundle can resolve it. Create a native application from its parent directory:

```sh
foundry new my_app --pretend
foundry new my_app
foundry new another_app --specs=openspec --agent=claude
foundry new offline_app --specs=none
```

The command uses the installed Rails version, ignores machine-wide `.railsrc` defaults, and invokes Rails' application generator with a native template. It bundles and initializes Rails integrations, then installs the selected specification workflow and Foundry skills. Missing workflow prerequisites fail before creating the destination. An existing destination is always rejected; use adoption or setup for existing applications. `--root=PATH` selects the parent directory; `--database=sqlite3` is available for a local consumer, and `--skip-git` and `--skip-dev-gems` are supported. For other Rails options, use Rails directly and configure Foundry in the resulting application.

Defaults are PostgreSQL, Puma, Hotwire, and Solid Queue 1.7.x with no additional cache service. PostgreSQL also supplies the optional Action Cable transport; SQLite uses the process-local async Cable adapter and is not the distributed-realtime recipe. Foundry uses Solid Queue's upstream installer and single-database recipe: queue tables live in a root migration alongside application tables. Run `bin/rails db:prepare` before starting Rails or `bin/jobs`. Ordinary application writes remain synchronous. The generated test environment uses Active Job's test adapter.

The generated Gemfile explicitly includes `packs-rails`, `dry-operation`, and `solid_queue` as application dependencies. It constrains JSON to `>= 2.9, < 3`: job persistence exposed Rails 8.1.3.1 passing positional options to JSON 3's keyword-only parser. This constraint belongs to the tested application recipe; it does not change the core gem's JSON compatibility tests. Foundry is limited to development/test. Production can exclude those development groups and load generated components without the Foundry gem. Foundry has no application loader or runtime.

A failed or interrupted creation preserves its files and `.foundry/new-in-progress`. Inspect Rails output, the bundle, integration files, and workflow journals before recovery; `foundry new` will not overwrite that directory on retry. `foundry setup` only repairs or selects the specification workflow, not a failed Rails bundle or integration installation. The native template is for fresh generation, not a repeat migration script.

Keep the Foundry repository on its existing OpenSpec workflow. In a consuming Rails application, choose a workflow explicitly or preserve an established selection:

```sh
bundle exec foundry setup --specs=spec-kit --pretend
bundle exec foundry setup --specs=spec-kit
bundle exec foundry setup --specs=openspec
bundle exec foundry setup --specs=none
bundle exec foundry doctor
```

`setup --greenfield` defaults to Spec Kit only when no selection or unambiguous local tooling exists. Setup of an existing application defaults to OpenSpec. Explicit selection overrides configuration; configuration overrides detection. Both detected without a selection is an error. Detection never inherits tooling from a parent repository. `--agent=codex|claude|cursor` selects upstream agent setup for a new installation; existing installations are preserved and additional integrations should use upstream tooling.

The selected value is stored in `config/foundry.yml` as `workflow.specs: spec_kit|openspec|none`. Other configuration keys survive. None needs neither workflow tool and deletes nothing. Switching does not convert specifications or remove history.

Foundry tests Specify CLI 1.0.0 and OpenSpec 1.12.0. Install prerequisites explicitly:

```sh
# Spec Kit: Python 3.11+ and uv, or use pipx with the same source URL.
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git@v1.0.0

# OpenSpec: Node 20.19+; application-local development dependency.
npm install --save-dev --save-exact @fission-ai/openspec@1.12.0
```

Initialization invokes the pinned native tools in a temporary staging directory and preflights generated destinations. Preview does not modify the consumer. Existing artifacts, partial installations, missing tooling, and version mismatch produce diagnostics. A process interrupted during publication leaves `.foundry/workflow-setup-in-progress`; inspect its file list before repairing and retrying. No background retry removes user files. Doctor is read-only and checks tool availability separately from installed markers.

## Explicit boundary verification

Opt into boot-free source boundary diagnostics separately:

```sh
foundry check --sources
foundry adopt --sources --format=json
bin/rails foundry:architecture:sources
```

This parses Ruby under application `app/` and each discovered context's `app/` where a Foundry sidecar exists, including custom pack roots. It reports explicit `RailsAIFoundry` constant paths with a file, line, rule, `detected` certainty and boundary guidance. Comments and plain strings are ignored. Invalid Ruby and detected Foundry dependencies fail the command; adoption still makes no changes. `detected` means the syntax was found, not that Ruby constant resolution has been proven.

The check does not inspect unconfigured packs, `lib/`, initializers, ERB, requires, dynamic lookup or aliases; unqualified lexical references need manual review. A clean result does not prove runtime independence or correct transactions. Baselines and application source remain unchanged. Default configuration assessment does not run this check. `foundry check --sources --boundaries` requests both checks and fails if either fails; Packwerk alone owns dependency/privacy analysis.

`foundry plan refactor --context=NAME` uses the same AST diagnostics and boundary guidance, but scans all Ruby files inside its selected context, including tests. Findings are advisory for planning: Foundry dependencies do not fail a successfully parsed assessment. Unparseable files set `complete: false` and fail the command. Reports describe this scope and the same resolution limits; a proposed profile still changes no installed configuration or code.

In all consuming applications, `bin/rails foundry:check`, `foundry:architecture:check`, and `foundry:architecture:conventions` run the same boot-free native configuration assessment. Use `bin/rails foundry:architecture:boundaries` for explicit upstream Packwerk verification. The default task does not imply boundary verification.

Applications without root `config/foundry.yml` use the same native checks. Run `foundry setup --specs=none` or select a workflow to install configuration. Foundry has no package-loading initializer; remove obsolete `autoload_packages` settings.

`foundry check` remains a boot-free configuration check. Opt into upstream boundary checks with:

```sh
foundry check --boundaries
foundry check --boundaries --format=json
```

This runs the consuming bundle's Packwerk `validate`, then `check`, in separate processes with `RAILS_ENV=test`, `RACK_ENV=test` and frozen Bundler resolution. It requires an installed `Gemfile.lock` and `packwerk.yml`. Upstream validation also requires the application's root `package.yml`; native `foundry new` creates it. The subprocess explicitly requires the standard `stringio` library because Packwerk 3.1.0 references it before Rails boot. Foundry does not implement another boundary engine or substitute pks.

Run this against an isolated test environment: application boot can execute initializers and write logs/caches. Setting the Rails environment is not a filesystem or network sandbox. The default `foundry adopt` and structural `foundry check` commands remain read-only and do not request this boot. `--boundaries` is rejected for adoption.

Packwerk matches accepted `package_todo.yml` entries by its upstream identities, including source file, referenced constant, owning package and violation type. New references fail even when another file's reference to the same constant is accepted. Foundry compares baseline paths and contents before and after execution and fails on changes, preserving concurrent edits for inspection. It never invokes `update-todo`, regenerates debt, or automatically restores files. JSON includes upstream commands, output, exit statuses, baseline preservation and overall success.

Stale-debt diagnostics remain upstream behavior. Packwerk 3.1.0 can miss a fully resolved baseline when a package has no remaining violations; review those baselines separately. This command establishes neither complete debt-cleanup verification nor pks parity. Use application-specific parity verification before enabling pks, and keep behavioral tests separate from static checking.

## Application defaults and read-only adoption

Root defaults apply only when generating a new context. Explicit generator options override them; existing contexts keep their installed settings. Workload does not implicitly select a profile or pattern:

```yaml
# config/foundry.yml
workload: balanced
defaults:
  profile: modular
  patterns:
    events: none
    cqrs: queries
workflow:
  specs: spec_kit
```

Workloads are `balanced`, `read_heavy`, `job_heavy`, `ingestion`, and `realtime`. Defaults may contain `profile`, `patterns`, and `capabilities`. Context namespaces and ownership stay local. Known configuration shapes and values are validated before generation or workflow setup; unrelated application configuration is preserved. Checker and adoption policy mappings are retained for subsequent tooling; this increment does not execute policy-specific debt or parity checks.

```sh
bundle exec foundry adopt --format=json
bundle exec foundry check
```

Both commands inspect the consuming application without booting Rails, initializing a specification tool, or writing files. Adoption recommends OpenSpec only when no workflow is configured or detected. `--specs=spec-kit|openspec|none` changes the assessment's recommendation without changing the installed selection. An ambiguous installation needs an explicit selection. Run `foundry setup` separately when ready to install it.

Structural checking validates root configuration, context intent, and namespace ownership using upstream pack discovery. It reports its limited verification scope explicitly. Packs without Foundry sidecars remain valid during incremental adoption. These commands preserve source and accepted Packwerk debt.

Run `bundle exec packwerk validate` and `bundle exec packwerk check` separately in an isolated test environment to verify boundaries, then run the owning application's behavioral tests. Structural success is not evidence of dependency/privacy correctness or completed adoption.

## Packages and code

Native generation uses `--context=NAME` with ordinary Rails loading. Delivery entrypoints include `foundry:controller`, `foundry:job`, `foundry:mailer`, and `foundry:channel`; they generate classes inside the owning pack and inherit application shell base classes. For example, `bin/rails generate foundry:controller invoices --context=billing` defines `Billing::InvoicesController`. Add routes, views, actions and behavioral tests with ordinary Rails conventions.

Use standalone `bundle exec foundry setup` for workflow selection and `bin/rails generate foundry:context NAME` for context creation.

Native consumers use upstream `packs-rails` for Rails integration. Add it to the consumer Gemfile and bundle before booting the application. Foundry supplies no package loader.

```ruby
gem 'packs-rails', '~> 0.1.0'
gem 'dry-operation', '~> 1.1'
group :development, :test do
  gem 'rails_ai_foundry', path: '/path/to/rails-ai-foundry'
end
```

```sh
bin/rails generate foundry:context billing --profile=domain --pretend
bin/rails generate foundry:context billing --profile=domain
bin/rails generate foundry:context reporting --profile=modular --events=integration --cqrs=read_model
bin/rails generate foundry:command charge --context=billing
bin/rails generate foundry:model invoice --context=billing
bundle exec foundry plan refactor --context=billing --profile=modular --format=json
```

Context creation delegates to `packs` and defaults to `packs/NAME`. For an established custom root, retain `packs.yml` and pass `--path=components/billing`. `packs-specification` remains authoritative for discovery. New consumer Packwerk configuration enables `packwerk-extensions`; an existing configuration must already enable it before a private context is generated. Package creation does not run Rails or business code. Full Packwerk checks remain a separate application command and may boot Rails.

`package.yml` owns dependencies, privacy, public paths, and stewardship. Its adjacent `foundry.yml` owns intent:

```yaml
schema: 1
kind: domain
profile: domain
namespace: Billing
patterns:
  events: none
  cqrs: none
capabilities: {}
```

The supported profiles are `rails_native`, `modular`, and `domain`. Events (`none`, `integration`, `event_sourced`) and CQRS (`none`, `queries`, `read_model`) vary independently. Capability entries are keyed mappings with an adapter selection; accepting configuration does not establish an installed or verified integration. Unsupported profiles are rejected with the supported values.

Native paths use ordinary Rails autoload roots and Ruby namespaces. For example, the command above defines `Billing::Commands::Charge` under `packs/billing/app/application/billing/commands/charge.rb`. A modular command defines `Billing::Charge` under `app/commands/billing/charge.rb`. A rails-native command uses `app/operations/billing/charge.rb`.

Native commands inherit `Dry::Operation` directly. They use one explicit result boundary and a Rails savepoint; a failed result raises `ActiveRecord::Rollback` inside the transaction. The caller still decides whether to abort a larger enclosing transaction. Ordinary operations do not automatically open a transaction. Models inherit the application's `ApplicationRecord`; generate migrations using Rails at the application root. Constructor injection and direct upstream APIs are the default.

Scaffolds deliberately require implementation. Replace their exceptions with business behavior and test successful results, failed results, exceptions, and composition. Repeat generation preserves edited files when its receipt matches. Conflicts and incomplete scaffolds fail conservatively. Profile changes require reviewed source changes; editing intent does not move code or convert data.

Component generation also rejects a constant already claimed by another component receipt in the same pack, including during preview. A modular `operation quote` and `model quote` both define `Billing::Quote` and cannot coexist; domain `command quote` and `query quote` define different categorized constants and can coexist. This guard covers component and agent receipts; manually defined or dynamically created constants still need review. Continue verifying ordinary Rails eager loading.

## Verification

`test/native_rails_test.rb` verifies upstream loading, direct native results, failed-result and nested rollback, pack-owned routes/views/jobs, and reloading. Configuration and discovery tests remain boot-free. `bundle exec rake test:workflows` generates a real Rails consumer and exercises both real upstream tools, selection switching, repeat setup, parent isolation, and none. Install the pinned tools before this separate lane; there are no live model calls.

The [workflow skill reference](../skills/references/workflows.md) describes workflow-specific evidence and the recommended Spec Kit living-spec convention. Specification validation is never a substitute for behavioral tests.
