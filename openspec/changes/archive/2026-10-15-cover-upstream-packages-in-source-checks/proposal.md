## Why

Foundry already discovers ordinary upstream packages and verifies their tests, but its source checker selects only packages with a Foundry sidecar. A disposable reproduction at `46a0cf4` discovered `components/search` containing an explicit prohibited Foundry reference, yet `check --sources` returned success with zero files checked. Close that coverage gap before expanding the product again.

## What Changes

- Extend existing explicit `check --sources`, `adopt --sources` and the architecture source task to inspect root `app/` and every upstream-discovered package's `app/` Ruby files, including packages without `foundry.yml`.
- Reuse the assessment's upstream package inventory. Select files independently from architectural intent; do not invent a namespace or profile for unconfigured packages.
- Apply existing profile-independent syntax, development-dependency, delivery, query/projection and transaction rules to the expanded selection. Apply domain-profile rules only to files owned by an explicitly configured domain context.
- Normalize root-package paths, deduplicate overlapping selections, respect nested package ownership and reject unsafe paths without loading application code.
- Preserve existing report fields, diagnostic identifiers, severity/certainty meanings and optional-check semantics. Explicit checks may now fail on previously omitted code; document this coverage expansion rather than offering a silent fallback.
- Verify the built gem, update existing installed references and record controls proving that omission of an unconfigured package cannot yield accepted verification.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `native-source-diagnostics`: Expand source selection to all upstream packages, preserve intent-scoped rules and define safe, deterministic ownership and coverage behavior.

## Impact

Implementation targets are `SourceCheck`, its assessment integration, architecture-rule context selection and focused source/packaged tests. Reuse upstream discovery through `Contexts` and existing safe-file access. The selected-context refactor planner must retain its existing scope and semantics when shared rules change.

Update source diagnostics, stable-contract documentation, relevant existing skill references and the roadmap after verification. Add any new distributable implementation resource explicitly to `packaging/files.txt`.

Keep all existing locked dependencies, Ruby/Rails floors, eight skills, twelve applications, command options and configuration/report schemas unchanged. No template analyzer, runtime, automatic repair, broader prompt discovery, test-harness change, provider call, agent trial or new tutorial application is included. Campfire's native-test blockers, the unfinished guidance study and hosted release gate remain open and separately attributed. This is a proposed change; baseline specifications remain unchanged until verified implementation.
