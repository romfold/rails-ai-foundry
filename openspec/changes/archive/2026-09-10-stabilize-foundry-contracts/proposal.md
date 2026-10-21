## Why

The native implementation and twelve-app corpus are verified through 0.5, but consumers cannot yet identify a stable machine-readable report contract or a complete supported configuration schema. The 1.0 boundary must make upgrades reviewable without introducing application execution machinery.

## What Changes

- Ship versioned application/context and diagnostic/report JSON Schemas in the built gem, and expose a boot-free contracts inventory and version command.
- **BREAKING**: reject unknown root configuration, unsupported root schema versions and nonempty reserved checker/adoption policy mappings instead of silently ignoring settings. Preserve schema-omitted 0.2–0.5 inputs as version 1.
- Add report schema/version/kind metadata to JSON assessments, refactor plans and audit/parity evidence; reject unsupported parity evidence formats with rerun guidance.
- Freeze documented generator placement, receipt ownership, skill names/targets and collision/retry behavior. Verify upgrades from the committed 0.5 skill catalog without rewriting customized files.
- Document SemVer, deprecation, compatibility tiers, upgrade/recovery procedures and release acceptance; align shipped metadata at 1.0.0 without publishing.

## Capabilities

### New Capabilities
- `stable-contracts`: Versioned configuration and diagnostic contracts, distribution, consumer upgrade guarantees and support policy.

### Modified Capabilities

None. Existing native behavior remains; the new contract adds strict validation and version identification.

## Impact

Development-time configuration validation, CLI reports, gem assets, contract acceptance, documentation, skills and version locks. No new production dependencies, runtime, data conversion, upstream workflow template fork or automatic scaffold migration. Existing optional recipes retain their own support tiers and prior evidence.
