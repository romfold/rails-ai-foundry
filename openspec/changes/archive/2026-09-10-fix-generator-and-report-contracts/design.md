## Context

See proposal.md for the reproduced failures. Capture returns locale-tagged strings, receipts currently separate components and agents, and namespace paths are underscored without loading configuration.

## Goals / Non-Goals

Keep the public schema/version stable and preserve boot-free inspection, edited output and upstream debt. Do not implement semantic architecture checks, provider integrations or hosted release verification.

## Decisions

- Decode report subprocess bytes as UTF-8 and scrub invalid sequences at capture boundaries, shared by boundary and audit/parity execution. Do not mutate environment locale or hide failed commands.
- Share constant ownership discovery over existing component and agent receipts. Infer agent/tool/schema constants from the namespace and receipt name; retain receipt bytes and compare complete constant paths.
- Generate per-context initializer files using Rails autoloader inflector overrides, not global ActiveSupport acronym registration. This retains existing underscored paths and avoids altering table naming. Compute required overrides against ordinary basename capitalization independently of application boot.
- Use a deterministic digest of the context's relative pack path for the initializer filename, and a separate pack-local inflection receipt. Detect incompatible basename mappings across every configured context's namespace segments, including ordinary spellings such as Api. Application-owned custom initializers remain outside static semantic validation.
- Preflight primary and supplemental inflection scaffolds before writing either, then install new files in one rollback boundary. Complete primary repeats remain unchanged. New artifacts in existing contexts can install missing inflections, while partial supplemental ownership refuses.

## Risks / Trade-offs

- Basename overrides affect the Rails loaders globally: reject conflicts among known context namespaces and document that custom application inflectors and unconfigured code still require eager-load acceptance.
- Edited initializers remain owned by the application: preservation does not prove their behavior; fresh-process tests provide behavioral evidence.
- Existing acronym scaffolds must not be silently refreshed: document manual repair from a disposable generated example, preserving old receipts.

## Migration Plan

No configuration schema or receipt conversion. Install updated tooling, review generated supplemental artifacts, and run owning loading tests. Rollback uses the reviewed application diff and prior gem selection. Retain the separate pending hosted CI change.
