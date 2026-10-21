## Why

The repository foundation provides a development workflow but no usable framework runtime. A small installation and structural-validation core will establish a testable application contract before AI integrations and richer generators depend on it.

## What Changes

- Introduce the proposed `rails_ai_foundry` gem and `RailsAIFoundry` namespace with Rails generator and task integration.
- Add `bin/rails generate foundry:install` to create a minimal application architecture manifest safely.
- Define versioned domain/platform package conventions and validate agreement between the manifest and package metadata.
- Add `bin/rails foundry:architecture:check` with deterministic diagnostics, meaningful exit status, and no writes or external-service calls from the checker.
- Test installation, repeat installation, invalid configuration, package consistency, and declared dependency rules using a minimal Rails host and filesystem fixtures.

This change is approved for implementation. Tasks are completed only after their verification passes.

- Add MIT licensing and verify Ruby 3.0+ / Rails 7.1+ compatibility across the approved matrix.

## Capabilities

### New Capabilities

- `framework-installation`: Install the framework into a Rails host while preserving existing application files and configuration.
- `package-configuration`: Describe domain and platform packages through a versioned manifest and predictable filesystem conventions.
- `architecture-validation`: Report configuration, package-layout, metadata, and declared dependency violations without modifying the application.

### Modified Capabilities

- `contributor-workflow`: Update the capability-status scenario to reflect the implemented core while keeping future work explicit and archived foundation records unchanged.

## Impact

Future implementation adds gem source, installation templates, Rails task integration, Ruby tooling, and tests at the monorepo root. Consumer applications gain `config/architecture.yml` and a package root. Public interfaces are the gem require path, installation generator, manifest format, package layout, and architecture-check task.

The first checker covers declared structure, not arbitrary Ruby calls, runtime authorization, or semantic architecture guarantees. Packwerk execution/privacy enforcement, custom package autoload integration, context generators, AI providers, databases, advanced profiles, brownfield adoption, and publishing are outside this change. The gem declares Ruby >= 3.0 and railties >= 7.1, with compatible Ruby/Rails pairs verified in the test matrix. It is distributed under MIT with a local version of 0.1.0; publishing remains out of scope.
