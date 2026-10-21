## Context

See proposal.md. Existing templates use three legacy roots, while every profile already supports the external adapter category. Existing receipts compare complete path lists and preserve customized content.

## Goals / Non-Goals

Support optional existing AI scaffolds within the four profiles without adding another architecture interpretation. Do not introduce provider abstraction, automatic migration, new AI behavior, or catalog entries.

## Decisions

- Resolve v2 Ruby directories through `Profiles.directory('adapter', namespace)`; place agent, tool, and schema directly there. Their constants end in `Adapters::External::<Name>Agent/Tool/Schema`. Avoid new AI roots or implicit collapsing. Mirror adapters/external in package tests.
- Keep shared templates and legacy rendering byte-identical. Derive prompt traversal from the actual generated source directory. V2 receipts identify the layout, not a particular profile, allowing promotion between profiles without needless incompatibility.
- Preflight convention validity for profiled packages and existing legacy destinations before writes. Never migrate user classes, references, prompts, or receipts automatically.
- Reject direct RubyLLM constants and requires in application/domain code and projections in profiled packages, while preserving legacy checks. This enforces the approved adapter ownership even in light profiles.
- Keep tool delegation unchanged: applications inject a callable which maps dry-operation success/failure into explicitly allowlisted JSON-compatible tool results. Verify that mapping through composition and a public API in archive acceptance; do not guess business failure policies in the gem.
- Bundle optional AI guidance in the existing seven skills, using the same registry-generated convention reference. Updated catalog digests continue to require explicit manual reconciliation.
- Retain RubyLLM ~> 1.16.0. Its public agent inputs and injected tools remain the integration API; no new dependencies are needed by core.

## Risks / Trade-offs

- Legacy scaffolds already inside v2 packages cannot be moved safely automatically → stop with paths and manual migration steps.
- Static checks cannot prove authorization, result serialization, or provider behavior → deterministic runtime success/failure tests plus explicit guidance; never call a provider during acceptance.
- Changed skill digests affect existing installations → preserve customized catalogs and retain manual review.

## Migration Plan

New generation uses canonical paths. Existing v1 consumers are unchanged. For existing v2 legacy scaffolds, commit a backup, preview the expected layout in an isolated package, manually move and rename classes and update references/prompt traversal/tests, reconcile the receipt only after review, then run strict checks and runtime tests. Roll back the application commit if verification fails. No data migration is involved.
