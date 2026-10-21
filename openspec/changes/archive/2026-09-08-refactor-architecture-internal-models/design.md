## Context

Manifest currently retains mutable string-keyed entries. Profiles supplies profile triples and formatted component paths. LayerRules checks containers first, then returns immediately for domain references, followed by AI isolation and application rules. Existing projection external-effect protection is already implemented.

## Goals / Non-Goals

**Goals:** Provide immutable snapshots for internal decisions, preserve mutable compatibility interfaces, and make each existing layer policy independently testable.

**Non-Goals:** New profiles, changed paths, caching mutable manifests, new diagnostics, stronger static guarantees, or runtime/event changes.

## Decisions

- Add Package, Profile, and ComponentLocation objects. Each copies and freezes strings and nested arrays/hashes; callers cannot mutate original inputs through a value. Package owns canonical package/namespace/public-entry paths. Profile owns the existing DDD/CQRS/event dimensions. ComponentLocation owns a component's kind and canonical directory.
- Manifest#package(name) and typed package enumeration construct snapshots from current hash contents on every call. Existing packages, profile(name), namespace_path, package_path, entry_path, and to_h retain their return types and values. No memoized view can hide hash edits.
- Keep Profiles' current helper API as delegation to the typed model. This reduces migration risk for existing internal consumers while callers migrate to typed accessors where appropriate.
- Extract six focused rule classes and use an explicit ordered dispatch. Container rules precede domain handling. Domain handling remains terminal even when it finds no violation. AI precedes projection effects, which precede command/read separation and application ports. Keep require checks and exact messages unchanged.
- Use table-driven equivalence cases, mixed violations, copied nested-input mutation tests, and YAML round trips alongside existing installed generator/runtime suites. Do not alter generated source.

## Risks / Trade-offs

- Fresh snapshots allocate more objects than cached views; correctness with the existing mutable hash contract takes precedence. No timing claim is made.
- Rule dispatch could change which message wins; overlap cases and domain-terminal cases assert exact output.
- Freezing caller-owned collections would break consumers; copy before freezing and test input mutation independently.

## Migration Plan

Verify and commit generation internals first. Introduce values and compatibility delegation, migrate internal decisions, then split rules. Run core and installed-profile regressions, RuboCop and strict OpenSpec validation. Archive only on passing evidence. Revert the isolated refactor commit to roll back; no application data migration is needed.
