# Package operations with upstream packs

Source checks include every discovered package's app/ Ruby files, including packages
without foundry.yml. A sidecar supplies architectural intent, not eligibility for general
checks. Nested packages do not inherit a parent's profile. Inspect source counts and
findings, then run Packwerk and behavioral tests independently; do not add a sidecar just
to obtain source coverage.

Use this reference when creating, exposing, moving or inspecting a context. Foundry is built on Rails, packs, packs-rails and Packwerk. `packs-specification` discovers topology; `packs` changes packages; `packs-rails` supplies Rails integration; Packwerk/extensions own dependency, privacy and cycle checks. Foundry adds architectural intent and guidance.

## Prepare the consuming application

Read its Gemfile.lock, packs.yml, packwerk.yml, package.yml, adjacent foundry.yml files and workflow selection. Work from that application root. Keep packs-rails in every environment; keep Foundry and analysis tools in development/test. Commands below target packs 0.3.0; inspect the locked CLI before using another version.

```sh
bundle exec packs help
bundle exec packs help create
```

`bundle binstubs packwerk` creates bin/packwerk, required by upstream validation and dependency-edit commands. An optional `bundle binstubs packs` creates bin/packs. Review existing binstubs before generation; do not force replacement. Upstream `packs check` and `packs validate` invoke bin/packwerk (or pks if explicitly configured). Without binstubs, use `bundle exec packwerk check` and `bundle exec packwerk validate` directly. Keep Packwerk authoritative; enabling pks requires application-specific parity evidence.

## Create and constrain a context

Resolve the intended path, namespace, profile, event pattern and CQRS pattern before writing files. Apply explicitly requested changes; otherwise preserve an existing context's sidecar. For a new context, use root `config/foundry.yml` defaults for choices the request leaves open (`rails_native`, events `none`, CQRS `none` when no defaults are configured). Root defaults do not rewrite existing contexts. Package extraction alone does not select a profile, and using Active Record does not imply `rails_native`.

Create a plain package with explicit enforcement choices:

```sh
bundle exec packs create packs/billing --enforce-dependencies --enforce-privacy --no-enforce-layers
```

Before creation, ensure packwerk.yml loads packwerk-extensions for privacy checking. Review upstream output and add an adjacent packs/billing/foundry.yml using the resolved choices. This example assumes `rails_native` with no event or CQRS pattern; substitute the selected values. For example, root `defaults.profile: modular` means a new context uses `profile: modular` unless explicitly overridden. Preserve independently selected patterns as well.

```yaml
schema: 1
namespace: Billing
profile: rails_native
patterns:
  events: none
  cqrs: none
capabilities: {}
```

When the intended boundary requires dependency and privacy enforcement, confirm both `enforce_dependencies: true` and `enforce_privacy: true` in the resulting `package.yml`. Setting `public_path` alone does not enable privacy. A passing Packwerk check proves only the policies actually enabled. In a disposable copy, add a cross-package reference to a private constant and confirm Packwerk rejects it, then remove the probe and confirm the public API caller passes. Do not weaken existing packages or accepted debt to make this check pass.

Place this file at `packs/billing/foundry.yml`, beside `packs/billing/package.yml`, not under the pack's `config/` directory. Keep workflow selection and application defaults in root `config/foundry.yml`; do not copy those fields into context intent. After extraction, inspect `foundry check --sources --format=json` and compare the context's path, namespace, profile and patterns against the choices resolved before editing. Reconcile differences before declaring completion. `success: true` means the installed configuration is valid; it cannot prove that it matches the user's requested architecture.

The package.yml owns dependencies/public paths/stewardship; foundry.yml owns architecture. A plain upstream pack does not receive Foundry intent automatically. Existing packs without a sidecar remain valid for incremental adoption. The optional `bin/rails generate foundry:context billing --pretend` previews a combined scaffold using application defaults. Add `--profile=modular`, for example, only when that is the selected override; `--events` and `--cqrs` remain independent. Remove --pretend only when that scaffold is wanted. Neither route implements a feature.

## Dependencies and public APIs

```sh
bundle exec packs add_dependency packs/billing packs/customers
bundle exec packs get_info packs/billing
bundle exec packs list_top_violations privacy packs/customers --limit=10
```

add_dependency mutates and normalizes the source package.yml and then runs bin/packwerk validate. Preflight that binstub and use an isolated Rails environment; a validation failure can leave the dependency edit in place. It permits a dependency, not private access. Expose a narrow public API under the destination package's actual public_path (normally app/public), and keep private Active Record objects inside their owner. Same-pack controllers/jobs can use internal objects. Violation summaries read accepted debt; they are not fresh source analysis.

Feature controllers, views, jobs, channels, mailers, agents, tools and schemas stay in the pack. Rails base classes and shared delivery stay in the shell; migrations stay at root. Use explicit namespaces and ordinary autoload roots: app/models/billing/invoice.rb defines Billing::Invoice. A pack can own config/routes/billing.rb; draw :billing from root config/routes.rb. Keep tests in the pack and pass their paths explicitly to Rails test commands.

## Custom roots and moves

Honor pack_paths in packs.yml, including nested configured roots; do not infer ownership solely from the packs/ prefix. Create at the intended upstream path and use that exact path for dependencies. For optional Foundry scaffolding, supply --path=components/billing. Nested directories do not establish Ruby namespaces automatically.

`packs make_public PATH` moves code to the public path. `packs move DESTINATION_PACK PATH` moves code between owners. `packs rename` is interactive in 0.3.0; it does not take invented old/new positional arguments. `move_to_parent CHILD PARENT` and `move_to_folder PACK DIRECTORY` change topology. These commands can rewrite source, metadata and debt through upstream post-processors. Use them in a reviewed branch with a clean baseline and inspect every change.

After a move, review Ruby namespaces, references, routes, tests, public paths, foundry.yml, prompt lookup and .foundry receipts. Packs does not reconcile Foundry receipts. Do not edit hashes to make a generator accept moved code. Preserve the original receipt as provenance; explicitly relocate/reconcile owned artifacts with a disposable fresh scaffold when necessary. Verify fresh-process Rails loading and behavior before accepting the move.

## Checks and debt

```sh
bundle exec foundry check --sources
RAILS_ENV=test bundle exec packwerk validate
RAILS_ENV=test bundle exec packwerk check
bin/rails zeitwerk:check
bin/rails test packs/billing/test
```

Full Packwerk checks can boot Rails; use an isolated environment/database. `foundry check --boundaries` also verifies accepted debt bytes stay unchanged. Record behavioral tests separately from static evidence. Do not run `packs update` (update-todo) during normal no-new-debt checks. `packs lint_package_todo_yml_files` also invokes debt regeneration in 0.3.0, despite its name. Review formatting/move operations for writes; never silently accept regenerated debt. Use Foundry audit in a disposable copy to propose resolved-debt cleanup.

Upstream references: [packs](https://github.com/rubyatscale/packs), [packs-rails](https://github.com/rubyatscale/packs-rails).

For everyday feature verification, opt in to the installed helper's `--include-pack-tests`
so root and upstream-discovered package tests share one non-system baseline. Keep caller
and browser selections explicit. Copy and adapt the installed gem's
`docs/package-aware-verification.md` into an application-owned `bin/verify-feature`;
preserve existing commands and require separate invocations for mixed frameworks.
Deliver helper updates through reviewed skill upgrades, then execute behavioral checks.
