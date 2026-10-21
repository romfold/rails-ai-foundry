## Context

See proposal.md for motivation. The gem already supplies a safe installer, literal YAML parsing, a structural checker, and Rails tasks. Ruby 3.0 syntax and the seven documented upstream-compatible pairs remain mandatory.

## Goals / Non-Goals

**Goals:** Minimal safe generation and opt-in standard Rails loading.
**Non-Goals:** Engines, a second loader, dependency/privacy enforcement, business scaffolding, custom inflection policy, automatic routing/view/asset integration, or release work.

## Decisions

### Generation and registration

Use a plain Ruby package plan and installer behind the Rails generator. Reuse schema, graph, filesystem, and conservative creation/cleanup behavior. Validate existing structure before planning; validate the proposed registry before deriving paths. Compare dependency sets independent of order. A repeated request requires metadata, public module, and generated test to exist as real files; preserve their customized bytes.

Generate `package.yml`, the existing public module path, and `test/<identifier>_test.rb` beneath the package. The test requires the application's test_helper and asserts that the public constant is a Module. Prefix platform test classes to avoid domain/platform ambiguity. Do not enable loading or change the host test helper automatically.

Write package files using exclusive creation, creating only missing ancestor directories. Capture source manifest bytes, identity, and permissions. Write normalized YAML to an exclusive temporary file beside the manifest, preserve its mode, recheck the source, then rename the temporary file over it as the final mutation. Journal new files and directories for conservative rollback; preserve changed content and report leftovers. This avoids destructive overwrite prompts and a formatting-edit dependency.

### Rails lifecycle

Set OrderedOptions configuration with autoload_packages false. An initializer before Rails' set_load_path (which can cache autoload paths on Rails 7.1) validates and registers immediate app directories, except assets/views, in both config.autoload_paths and config.eager_load_paths. Rails sets up its main loader later; no custom loader or manual package require is needed. Nested directories remain ordinary Zeitwerk namespaces, without special collapse rules. No Foundry-specific acronym overrides are installed.

The structural rake task has no environment prerequisite, so this initializer never runs during structural checks. A separate bootable test host covers runtime behavior while preserving the original hostile-to-boot host.

## Risks / Trade-offs

- Multiple writers and files are not an atomic transaction: recheck manifest identity/content before replacement and preserve modified artifacts during cleanup; document avoiding simultaneous changes.
- Normalization discards comments: explicitly document it and leave repeats byte-for-byte unchanged.
- Autoloading does not enforce isolation: document standard naming behavior and keep Packwerk separate.
- Registering paths changes boot behavior: default off and fail clearly only when enabled.
- New directories/registry entries need loader setup: document restart after registration changes.

## Migration Plan

Existing consumers keep default behavior. Generate packages, enable loading explicitly in config/application.rb, and restart. Remove the opt-in to disable loading; review application diffs for removal of generated packages. Retain gem version 0.1.0 and MIT. Verify, merge specifications, and archive only after all tests and packaging checks pass.
