## Context

See [proposal.md](proposal.md) for motivation and scope. The repository has local OpenSpec tooling and an archived contributor-workflow baseline, but no Gemfile, gem source, Rails host, or Ruby tests. This document defines the approved first runtime change, including Ruby 3.0+ / Rails 7.1+ compatibility and MIT licensing.

## Goals / Non-Goals

**Goals:** Supply a small gem integration, a safe installer, a versioned application package contract, and a useful structural check that can run without full application initialization.

**Non-Goals:** Implement context generators, custom package autoloading, Packwerk execution or privacy extensions, AI conventions, business logic, database access, advanced architecture profiles, legacy-debt baselines, or release automation. Package entry paths are structural conventions in this change; their presence does not automatically make package constants autoloadable in a host.

## Decisions

### 1. Use a gem with a Railtie

Name the gem `rails_ai_foundry`, its require path `rails_ai_foundry`, and its namespace `RailsAIFoundry`. Keep the gem at the monorepo root. Use a Railtie to register the rake task and standard Rails generator discovery for `foundry:install`. The pure Ruby entry point exposes the namespace and version without requiring a running Rails app; conditionally load Rails integration when the Rails framework is present.

A Railtie is the appropriate extension point for tasks and initialization integration, whereas an Engine would introduce application components this change does not need. Follow the [Rails plugin guide](https://guides.rubyonrails.org/plugins.html) and [generator guide](https://guides.rubyonrails.org/generators.html). Put the installer under the conventional `lib/generators/foundry/install/` hierarchy with its templates, and load its task through the Railtie's rake-task hook.

The only initial framework dependency is `railties`; keep parsing and validation in plain Ruby using Psych and filesystem APIs. Use Minitest for unit/generator tests and a minimal `test/dummy` Rails host for process-level checks. Add a root Gemfile, gemspec, Rakefile, and RuboCop configuration when implementing. Do not scaffold a new Rails application over the existing repository or replace the OpenSpec/npm files.

### 2. Version a small application manifest

The installer creates this exact initial data shape:

```yaml
version: 1
packages: {}
```

A populated example is:

```yaml
version: 1
packages:
  billing:
    type: domain
    dependencies:
      - messaging
  messaging:
    type: platform
    dependencies: []
```

Both top-level fields are required. Each package mapping requires exactly `type` and `dependencies`. Identifiers fully match `[a-z][a-z0-9]*(?:_[a-z0-9]+)*`; `platform` is reserved. Dependency lists contain distinct identifiers. Only integer version 1 is supported. Reject unknown manifest fields instead of silently ignoring misspelled configuration. Validate references, self-dependencies, cycles, and platform-to-domain edges after schema validation.

Paths and namespaces are derived, not separately configured. This avoids redundant values that could drift. Domain `billing` maps to root `packages/billing` and conventional namespace `Billing`; platform `messaging` maps to root `packages/platform/messaging` and `Platform::Messaging`. Snake_case names map to CamelCase without custom acronym configuration in this initial convention. Namespace semantics are documented, not inferred by parsing Ruby code in this checker.

The application manifest is the architecture source of truth. The Foundry monorepo itself does not gain a root application manifest.

### 3. Keep package structure explicit

The minimum declared domain package layout is:

```text
packages/billing/
  package.yml
  app/
    public/
      billing.rb
```

A platform package uses `packages/platform/messaging/app/public/platform/messaging.rb`. Additional app subdirectories and test files are unrestricted by the first checker. Package Ruby files are inspected for existence only, never required or evaluated. A later change must address loader integration and public API enforcement before claiming executable package isolation.

Each `package.yml` must contain `enforce_dependencies: true` and an explicit `dependencies` array of canonical application-relative paths. For the billing example:

```yaml
enforce_dependencies: true
dependencies:
  - packages/platform/messaging
```

An empty dependency set is written as `dependencies: []`. Order is immaterial; duplicate paths are invalid. Other data-only metadata keys are ignored and preserved. These fields follow [Packwerk's package configuration](https://github.com/Shopify/packwerk/blob/main/USAGE.md). Foundry compares them with the manifest but does not run Packwerk. Later integration must verify its own version compatibility, autoload configuration, and enforcement behavior; the flag alone does not prove a code boundary is enforced.

The `packages/` root itself is required even for an empty registry; report its absence as `package.missing`. Discover undeclared packages by looking for `package.yml` under the package root without following symlinks. Directories lacking metadata are not automatically packages. Validate every declared root, metadata file, app directory, and public entry path. Refuse symbolic links anywhere in inspected package paths, reporting `path.unsafe` rather than traversing them. Resolve the application root once and apply containment checks below that root, so platform nesting cannot escape it.

### 4. Separate read-only validation from installation

Use three internal responsibilities: parse/validate the manifest, inspect package structure/metadata, and present a report. Keep them independent of Rails application initialization. Require a single YAML document and use Psych's syntax tree to reject duplicate keys before converting mappings; load only primitive data and reject aliases and custom tags. Reject ERB-style delimiters without evaluating them. Apply the same safe parsing policy to package metadata, while allowing its extra keys.

For `foundry:install`, preflight the existing manifest and all managed destination types before writing. A supported schema-valid manifest with a valid declared graph is preserved byte-for-byte, even if its package layout needs a later fix. The installer does not perform package repair. Create a missing manifest and `packages/.keep`; preserve an existing regular `.keep` file. Never modify the Gemfile, application boot configuration, or existing package metadata.

Reject symlinks in managed paths and known conflicts before any write. On an unexpected write failure, report the path and clean up only newly created artifacts still matching this invocation's generated contents. Preserve existing or concurrently changed content; report cleanup leftovers. Do not add an overwrite mode. This conservative preflight behavior is preferable to Rails generator overwrite prompts for the managed manifest.

### 5. Make validation suitable for terminal use and later automation

Register `foundry:architecture:check` without an `environment` prerequisite. It uses the Rails host root to inspect files but does not initialize the host, load package Ruby code, or connect to services. A malformed manifest must still be diagnosable, so parsing belongs in command execution, not a boot initializer. A host can have its own task-loading side effects; the Foundry task must not add any.

Check in stages: manifest safety and parsing, manifest shape, declared graph, then package discovery/layout/metadata. If parsing or shape fails, skip checks that depend on a valid manifest. With a valid shape, collect independently actionable graph and package errors together; suppress diagnostics derived only from another reported failure, such as child files of an absent package root.

Use these diagnostic identifiers:

| Identifier | Meaning |
| --- | --- |
| `manifest.missing` | Installation/configuration is absent |
| `manifest.invalid` | Parse, duplicate-key, schema, or unsafe-data error |
| `manifest.version` | Unsupported format version |
| `path.unsafe` | Symbolic link or containment violation |
| `package.missing` | Required package directory or entry file absent |
| `package.unregistered` | Package metadata has no manifest declaration |
| `package.metadata` | Invalid or inconsistent package metadata |
| `dependency.invalid` | Unknown, self, or prohibited-direction dependency |
| `dependency.cycle` | Cycle across declared packages |
| `io.unreadable` | Required file/directory cannot be inspected |

Each error includes the application-relative path, identifier, contextual package/field, and corrective message; include a line for parse errors where available. Sort by path, identifier, package, and message. Send diagnostics and a failure count to stderr and exit 1. Emit `Foundry architecture structure: OK (N packages).` to stdout and exit 0 on success. Expected user configuration errors do not need a stack trace. Do not broadly swallow unexpected programming errors.

Do not expose internal report classes as supported public Ruby APIs in this change. A JSON report, auto-fix mode, parser for Ruby references, and configurable rule severities can be specified separately if needed.

### 6. Verify behavior without external infrastructure

Use temporary application copies for generator and checker tests. Compare before/after file contents for repeated installation and validation; use a package entry file with a detectable side effect to prove the checker does not load Ruby content. Cover malformed YAML, duplicate keys, unsupported versions, aliases/tags/templates, missing paths, symlinks, unregistered packages, metadata drift, graph errors, and deterministic multi-error output.

Use a minimal Rails host without Active Record or provider dependencies to exercise generator/task discovery, first install, repeat install, missing-manifest diagnostics, and process exit statuses. Simulate unreadable inputs and write failures deterministically rather than relying only on platform-specific permission bits. Run `bundle exec rake test`, `bundle exec rubocop` on changed Ruby paths, and `npm run spec:validate`. Build and inspect a local gem archive to confirm runtime source, task files, and installation templates are included while local dependencies and research are excluded.

## Risks / Trade-offs

- A structural check can create false confidence → Name its limited scope in success output and documentation; do not claim Ruby dependency, privacy, or domain correctness enforcement.
- Manifest and package metadata represent the same dependency set → Treat the manifest as authoritative and report drift without automatically rewriting either file.
- Multiple-file installation is not a filesystem transaction → Preflight conflicts, preserve user files, test failure cleanup, and disclose any leftover generated artifacts.
- Package layout without automatic loading is only an initial convention → Keep loader integration explicitly separate and test no accidental package code execution in the checker.
- Dependency versions change → Verify supported stable Ruby/Rails compatibility at the start of runtime implementation, document the selected test matrix, and avoid copying research version claims.

## Migration Plan

Implement the gem, parser/checker, installer, and Rails integration against temporary test hosts. Add a minimal guide showing the exact manifest and package examples above, their structural limits, and recovery from diagnostics. No existing application is auto-migrated. Installing into a real host is an explicit action after adding the gem.

Unknown manifest versions fail with guidance instead of being upgraded implicitly. Roll back an application installation through its reviewed Git diff, retaining any subsequently authored package code. Keep this change active until runtime tests and implementation tasks pass; only then merge its specifications and archive it. Publishing remains separate release work; MIT licensing is included in this change.

## Compatibility and licensing

Declare `required_ruby_version >= 3.0` and `railties >= 7.1` in the gemspec. Use Ruby 3.0 syntax and RuboCop's Ruby 3.0 target. Develop with Ruby 3.4.10, preserving Node 20.19.0. Select the managed Ruby explicitly because system Ruby can precede asdf shims on PATH.

Use separate Rails-series Gemfiles for Rails 7.1, 7.2, 8.0, and 8.1. Test Ruby/Rails pairs 3.0/7.1, 3.1/7.2, 3.2/8.0, 3.3/8.1, 3.4/7.1, 3.4/8.1, and 4.0/8.1. Record exact resolved patch versions and use a compatible Bundler per Ruby. Do not claim unexecuted remote CI runs passed. Newer Rails versions retain their own Ruby minimums; the declared floors are not a guarantee of every Cartesian pairing.

Add the standard MIT license with copyright `2026 romfold`, include it in the gem, and set gem/npm license metadata to MIT. Preserve generated upstream license notices. Use gem version 0.1.0 locally without publishing.
