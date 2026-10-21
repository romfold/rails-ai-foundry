## Why

Foundry has no deployed consumers requiring support for retired releases. Maintaining obsolete configuration detection and migration recipes obscures the current conventions-only product.

## What Changes

- **BREAKING** Remove obsolete manifest detection, assessment report fields, profile-specific migration errors and command redirects.
- Replace retired-API migration recipes with a general development-only Foundry source boundary diagnostic.
- Remove current migration documentation and obsolete configuration examples; retain historical ADRs and archives.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `native-rails-checks`: describe current generator isolation without retired manifest contracts.
- `context-intent`: validate only current configuration and ignore unrelated documents/metadata.
- `native-source-diagnostics`: detect development-tool references without a retired API registry.
- `architecture-planning`: use current boundary diagnostics.
- `stable-contracts`: reset unpublished assessment and diagnostic contracts.

## Impact

Assessment JSON loses legacy_manifest; source diagnostics use source.foundry_dependency. No deployment or version compatibility layer is retained for the unpublished 1.0 candidate. Brownfield Rails adoption, Packwerk debt preservation and ordinary tool-version safety remain supported.
