## 1. Ruby foundation

- [x] 1.1 Configure Ruby >= 3.0 and railties >= 7.1 with the approved compatibility matrix, record exact runtime/test versions, and add the root Gemfile, gemspec, Rakefile, and development dependencies; verify `bundle install` succeeds without replacing existing repository tooling.
- [x] 1.2 Add the `rails_ai_foundry` require entry point, `RailsAIFoundry` namespace, and version; verify a plain Ruby require succeeds without a running Rails app or network/database access.
- [x] 1.3 Add Minitest setup and root RuboCop configuration following the contributor guide; verify a focused load test and lint of the initial Ruby files pass.

## 2. Manifest and structural validation

- [x] 2.1 Implement safe single-document manifest parsing and version 1 schema validation; verify fixtures for empty/populated registries, malformed YAML, duplicate keys, unknown fields, invalid identifiers/types/versions, duplicate dependencies, aliases, custom tags, and ERB-style input.
- [x] 2.2 Implement derived package paths and declared dependency validation; verify valid domain/platform dependencies, reserved identifiers, unknown references, self-dependencies, cycles, and prohibited platform-to-domain edges.
- [x] 2.3 Implement read-only package discovery and required-path checks without following symlinks; verify missing roots/entry files, wrong path types, unregistered metadata, ordinary directories, unsafe links, and simulated unreadable inputs.
- [x] 2.4 Validate package metadata against manifest dependencies while preserving extra data-only keys; verify missing/extra/duplicate paths, disabled enforcement, invalid YAML, and order-independent valid metadata.
- [x] 2.5 Implement the deterministic diagnostic report with the design's rule identifiers, source paths, and corrective messages; verify stable multi-error ordering, suppression of cascaded errors, success counts, and no writes or package Ruby execution.

## 3. Rails installation and command integration

- [x] 3.1 Implement `foundry:install` with destination preflight, minimal manifest generation, and package-root creation; verify first installation, unchanged repeated installation, and preservation of a customized compatible manifest and unrelated files.
- [x] 3.2 Handle installer conflicts and unexpected write failures conservatively; verify invalid configuration, symlink/wrong-type destinations, partial-write cleanup, and preservation of pre-existing or concurrently changed content.
- [x] 3.3 Register the generator and `foundry:architecture:check` through standard Rails integration without an environment prerequisite; verify discovery and task invocation with process-level exit statuses 0 and 1 and the documented stdout/stderr behavior.

## 4. End-to-end evidence and documentation

- [x] 4.1 Add a minimal Rails test host and integration scenarios for install, repeat install, missing manifest, a valid domain/platform fixture, and structural failures; verify the workflow runs without Active Record, AI credentials, or network services and does not initialize the full application environment.
- [x] 4.2 Document actual installation, manifest/package examples, diagnostics, and structural limitations; verify examples against the test host and keep autoload integration, Packwerk execution/privacy, and advanced capabilities clearly marked as future work.
- [x] 4.3 Build and inspect a local gem archive; verify it includes the runtime entry point, generator templates, and task files, and excludes dependencies, credentials, and private research. Do not publish it.
- [x] 4.4 Run `bundle exec rake test`, `bundle exec rubocop` on all changed Ruby paths, and `npm run spec:validate`; verify every requirement has implementation evidence before completing tasks and archiving this runtime change.

## 5. Compatibility and licensing

- [x] 5.1 Add the MIT license and gem/npm license metadata with version 0.1.0; verify copyright, upstream notices, and packaged license contents.
- [x] 5.2 Run the behavioral suite across all seven approved Ruby/Rails pairs using separate Gemfiles and compatible Bundlers; record concrete versions and passing local results separately from unexecuted remote CI.


## Verification record

Completed locally on 2026-09-05. All seven approved Ruby/Rails combinations passed 38 tests and 160 assertions each, with no failures, errors, or skips. Concrete versions and scope are recorded in `docs/compatibility.md`.

RuboCop passed for all Ruby files with a Ruby 3.0 target. A clean npm installation and strict OpenSpec validation passed. The 0.1.0 gem was built, inspected for its 15 runtime/documentation/license files, and installed into a temporary gem directory; first/repeated installation and checking passed from that installed archive. Local documentation links and English content were reviewed.

The current contributor-workflow capability-status scenario is updated through a delta; the archived foundation and upstream skills remain unchanged. No remote CI execution or publishing is claimed.
