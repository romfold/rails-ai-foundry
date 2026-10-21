# 0003: Minimal packages and opt-in Rails loading

- Status: Accepted
- Date: 2026-09-05

## Decision

Add minimal domain/platform package generation and explicit application opt-in for loading. Keep the version 1 registry and canonical paths, and use Rails' main loader for the complete lazy/reload/eager lifecycle.

Generate namespace modules and tests without business scaffolding. Normalize manifest YAML only when adding registration; exact repeats preserve content. Preserve validated data and permissions, publish registration last, and conservatively remove only unchanged artifacts created by a failed operation.

## Rationale

A dedicated package command separates generation from the foundation installer. An opt-in keeps existing structural-check users' boot behavior stable. Standard Rails loading avoids an additional loader and preserves ordinary filename-to-constant behavior. Register roots before Rails computes load paths, including the cached paths used in Rails 7.1.

YAML normalization avoids a formatting-edit dependency while maintaining one authoritative registry. It deliberately discards comments, as documented and selected for this milestone.

## Consequences

Applications explicitly enable loading after foundation installation and restart after package registration or root-directory changes. Generated tests use the host's standard test helper and must be invoked with their package paths.

Structural checking remains independent of boot and Ruby execution. Loading does not provide privacy, dependency enforcement, view/asset integration, or automatic routing. This milestone precedes RubyLLM conventions; compatibility floors, MIT licensing, and local version 0.1.0 remain unchanged.
