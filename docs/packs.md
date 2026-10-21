# Built on Rails and packs

| Foundation | Responsibility |
| --- | --- |
| Rails | Application execution, autoloading, persistence and delivery |
| packs-specification | Discover package topology, including configured custom roots |
| packs | Create and reorganize packages using upstream development tools |
| packs-rails | Integrate pack code, views, routes and other Rails paths in every environment |
| Packwerk and extensions | Validate dependencies, privacy and cycles |
| Foundry | Guide architecture and implementation, offer optional scaffolds and focused checks, ship skills and executable evidence |

Use the application's locked `bundle exec packs` directly. The [pack operations reference](../skills/references/packs.md) ships with every Foundry skill and documents creation, dependencies, public paths, moves, debt and custom roots. The [first-feature tutorial](first-feature.md) demonstrates this workflow with two contexts and persistent Rails behavior.

Keep `packs-rails` in all application environments. Foundry and package analysis tools belong to development/test. Foundry's dependency on packs makes its executable available in that bundle; there is no `foundry packs` facade. A Bundler-generated `bin/packs` is an optional convenience, not a Foundry command.

### Sidecar placement validation

A discovered non-root package must place Foundry intent beside `package.yml`, for example
`packs/billing/foundry.yml`. `packs/billing/config/foundry.yml` is rejected, even if the
canonical sidecar also exists. Correct it manually; checks never move or merge configuration.
Root `config/foundry.yml` remains application-owned. Ordinary upstream packages without a
sidecar remain valid. After extracting a Foundry context, verify its exact path, namespace
and profile in `foundry check --sources --format=json`; zero configured contexts is not
evidence of a completed extraction.

Resolve architectural choices before copying a sidecar example. Explicit requested changes
take precedence; otherwise retain existing context settings and use application defaults
for new contexts. Compare the reported profile and independent patterns with that selection.
Structural success does not establish that a valid configuration implements the requested
architecture. The optional context generator uses root defaults when its options are omitted.

For existing controllers, helpers, views and Hotwire assets, use the installed
[delivery extraction guide](delivery-pack-extraction.md). Its shell-first checkpoints
retain models and data while verifying both default and custom roots.
