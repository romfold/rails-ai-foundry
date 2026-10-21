## Context

See proposal.md. The helper currently hands an empty baseline argument list to native discovery, or replaces it with explicit paths. Reporters validate outcomes but do not attest which baseline files loaded. Package discovery is already delegated to packs-specification elsewhere in development tooling.

## Goals / Non-Goals

Combine conventional non-system root and pack tests without changing non-opt-in behavior. Keep browser selection explicit. No runtime, persisted verification manifest, task graph, result cache, service provisioning or affected-package heuristic.

## Decisions

- Run discovery in the consuming application's locked bundle without booting Rails. Use Packs.all, validate application-relative configured globs, canonical package paths and real file containment. Reject symbolic package aliases with ambiguous ownership. Deduplicate canonical test files and attribute nested packages by the most-specific upstream package path.
- The opt-in baseline is a sorted union of root/package test or spec conventions and explicit additions. Exclude system, fixtures, dummy and support subdirectories from automatic enumeration; report conventional system files and explicitly selected browser files as deferred. Reject explicit baseline system paths. Nonstandard test roots use explicit additions. Unsupported discovery overrides fail before tests.
- Use temporary discovery output and the existing process-group timeout discipline. The parent prints a relative inventory before launching any test phase. Missing dependencies or malformed output never fall back to native root-only discovery.
- Record actual loaded files using Ruby loaded features for native Rails/Minitest requires and RSpec's loaded_spec_files. Check the planned baseline is a subset. This bookkeeping is separate from executed example/test ownership; shared definitions need no invented outcomes. No prior successful result is reused.
- Document a short application-owned bin/verify-feature with fixed reviewed arguments, not a generator or new configuration source. Mixed applications execute separate required framework invocations.

## Risks / Trade-offs

Discovery follows documented naming conventions, not arbitrary dynamic runner customization. Reject unsupported overrides rather than silently narrow coverage. Loaded files do not establish adequate assertions or adversarial integrity. Explicit browser selections remain necessary; custom system-test placement must be selected as browser work. Opt-in full baselines can take longer.

## Migration Plan

Ship resources through the explicit inventory and reviewed skill upgrades. Existing commands remain unchanged until the option is selected. Applications retain their own scripts, customized skills, workflow and debt. Removing the option restores prior discovery behavior without changing application data.
