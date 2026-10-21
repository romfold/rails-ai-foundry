## Context

See proposal.md. Existing boundary inputs require a manifest; checks and loading already share conventional roots and constant resolution.

## Goals / Non-Goals

Support source inventory without evaluating an application. Do not infer business boundaries, move files, or introduce an adoption baseline in this change.

## Decisions

Allow the shared boundary-input collector to operate without a manifest for assessment only. Existing callers keep their strict default. Reuse RubyReferences and ConstantResolver for declaration/reference inventory. Collect real Packwerk dependency/privacy findings through its structured reference and checker APIs rather than parsing terminal output or duplicating enforcement rules. Preserve conventional-root limits and report uncovered Ruby files.

CLI output is deterministic version-1 JSON or readable text. Analysis errors fail; assess reports existing boundary debt without presenting it as an analysis failure. Add an installed adoption reference and seventh skill while retaining receipt-based manual catalog upgrades.

## Risks / Trade-offs

Static constant lookup cannot prove dynamic Ruby, inherited aliases, framework callbacks, custom autoloaders, or database ownership. Report unresolved references and keep runtime extraction tests separate. Applications without registered packages are unpartitioned, not certified compliant.
