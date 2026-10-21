## Context

Existing safe component scaffolds cover operations, models, ports, and events; the profile registry already defines the remaining full-domain locations. Convention checking currently validates folders and syntax. Packwerk retains package privacy and dependency checks.

## Goals / Non-Goals

Goals: usable domain components, explicit persistence boundaries, and useful static layer diagnostics.
Non-goals: infer business invariants, automatically implement repositories, or treat static analysis as a Ruby sandbox.

## Decisions

Use the same receipt-aware component engine for domain scaffolds and records. Pure domain scaffold tests use Minitest and explicitly require their source; persistence tests remain Rails-host tests. Repository scaffolds expose constructor-injected records and explicit contract methods without pretending to implement application-specific mapping.

Parse source into an AST without evaluation. Resolve lexical constant references against an index derived from canonical Rails roots, preserving ordinary category namespaces. Check forbidden dependencies by resolved owner and responsibility. Keep Packwerk responsible for its existing package-boundary guarantees and share source-root derivation rather than replacing it with a weaker folder check.

## Risks / Trade-offs

Dynamic constants, reflection, metaprogramming, external IO through injected objects, and read-only semantics cannot be proven statically. Document limits and test behavior in runtime and pure-Ruby hosts. Avoid loading application classes during checking.

## Migration Plan

Version 1 remains unchanged. New checks apply to profiled packages only; diagnostics identify canonical targets. Scaffolds never move or rewrite existing business code.
