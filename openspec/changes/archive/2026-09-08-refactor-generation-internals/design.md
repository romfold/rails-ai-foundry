## Context

Installers duplicate rollback and write loops. Explicit requires and resource paths depend on their current directory. Public runtime types must stay at the root.

## Goals / Non-Goals

Goals: one write lifecycle, scoped internals, stable output and safety. Non-goals: changed event semantics, value objects, generated-code changes or compatibility aliases.

## Decisions

ScaffoldInstaller accepts pre-write and final-publication hooks while callers retain preflight/repeat policy. ManifestWriter uses the same tracked writer and original source/snapshot verification. A shared structural guard returns validated manifests but does not replace snapshot checks. Error classes live in errors.rb. Files move into Generation, Setup and Promotion only after consolidation. All explicit requires and relative resource paths are adjusted, including packaged smoke tests.

## Risks / Trade-offs

Partial-write tracking and exclusive package-root creation are essential and remain unchanged. Publication is the final mutation; no callbacks follow it. Different repeat policies remain local rather than forcing receipt-based behavior onto package registration.

## Migration Plan

Update repository internal callers atomically; consumers retain runtime require paths and generated files. Revert this bounded refactor if acceptance fails. No data migration.
