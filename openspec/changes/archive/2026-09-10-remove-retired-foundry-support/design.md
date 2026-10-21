## Context

The unpublished candidate still recognizes retired manifests, profiles, commands and runtime names despite having no compatibility runtime or installed consumers.

## Goals / Non-Goals

Remove these product paths and current migration documentation. Preserve historical archives, Rails brownfield adoption, upstream dependency compatibility and receipt collision safety.

## Decisions

Read architectural intent only from current configuration. Reject unknown profiles uniformly. Remove the obsolete assessment field from schema 1 before publication. Replace the retired-constant replacement table with a generic source.foundry_dependency diagnostic for explicit Foundry namespace references. Keep AST limitations and source verification opt-in. Preserve tool-version receipt safety, which protects edits rather than providing retired runtime support.

## Risks / Trade-offs

This intentionally resets unpublished report contracts; no shim or version conversion ships. Generic source diagnostics provide boundary guidance, not per-API migration recipes. Prior release-candidate evidence remains historical and must not be presented as evidence for this changed candidate.
