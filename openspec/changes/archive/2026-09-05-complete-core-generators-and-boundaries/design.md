## Context

See proposal.md. Existing Installer supports exclusive writes and identity-aware rollback. Package metadata is compatible with Packwerk but only checked structurally. Loading uses each direct package app subdirectory as an autoload root.

## Goals / Non-Goals

Deliver plain operations and enforce static package boundaries without changing the structural command. No runtime interception, custom business DSL, dynamic Ruby proof, AI changes, or example work.

## Decisions

- Reuse Installer primitives through a conservative scaffold installer with a receipt. Store operations under their full package namespace and generate Minitest tests; use `--public` rather than exporting every operation. Keep existing agent generation unchanged.
- Use Packwerk `~> 3.1.0` and packwerk-extensions `~> 0.3.0`, loaded only by the boundary command. The 3.1 line supports the Ruby 3.0 floor; current 3.3 requires Ruby 3.3. Avoid inventing a partial Ruby constant parser. Future dependency upgrades require compatibility verification.
- Build a dedicated Packwerk configuration from validated manifest roots and override its public load_paths method with conventional app directories. Do not load consumer packwerk.yml, initializers, or source files. Disable caching and parallelism, reject baselines and bypass metadata, and check only app Ruby sources. Root application code has no dependency restriction but must respect package privacy; package-to-host references remain undeclared dependencies.
- Require `enforce_privacy: true` and `public_path: app/public` in package metadata. The existing structural checker continues ignoring these extra keys. Explicitly diagnose old packages rather than rewriting their configuration.

## Risks / Trade-offs

- Static constant resolution cannot prove dynamic calls, reflection, runtime object flows, or authorization. Document the supported conventional roots and unsupported custom inflections/namespaces; syntax errors fail visibly.
- Upstream APIs may change: constrain the Packwerk minor line and exercise it on minimum and current Rails/Ruby combinations.
- Source-tree symlinks or bypass configuration could hide code: validate inspected trees before passing explicit file paths to the analyzer.

## Migration Plan

New packages get enforcement metadata automatically. Existing applications opt into the new command after adding the documented privacy fields and resolving violations. Existing commands and loading defaults do not change. Keep the unfinished support desk active but deferred in project guidance.
