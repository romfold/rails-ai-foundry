## Why

Source verification now covers every upstream package, but prompt verification still selects only configured contexts: an unconfigured pack with uncontracted instructions passes with zero contracts checked. Prompt ownership also relies on a path prefix rather than actual package ownership, so nested packages can claim a parent's prompt root. Incremental adoption should not require architectural configuration merely to check application-owned AI artifacts.

## What Changes

- Expand existing opt-in `foundry check --prompts` to application and all upstream-discovered package prompt roots, including packages without `foundry.yml`.
- Resolve the deepest owning package before validating contract placement and owner. Apply namespace restrictions only from that owner's explicit configuration; infer no namespace or AI capability for unconfigured packages.
- Make enumeration deterministic and fail explicitly on unsafe paths, symlinks, discovery failures and selected artifacts that cannot be inspected. Keep templates and evaluation content unexecuted.
- Preserve prompt schema 1, diagnostic/report fields, generator requirements and existing CLI options. Broader coverage may reveal previously omitted violations.
- Verify installed consumers under both package roots, retain existing agent/runtime behavior, and deliver revised guidance through reviewed skill upgrades.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `prompt-contracts`: cover upstream packages independently of sidecars, enforce actual ownership and deterministic safe coverage, and state the evidence limits.

## Impact

Affected areas are `PromptCheck`, `PromptContract`, the assessment handoff, private package traversal/ownership helpers where needed, prompt/core/installed-AI acceptance, existing guidance and explicit packaging inventory. Reuse the established ownership policy without adding a public discovery abstraction.

No dependency version changes, new CLI command or option, configuration keys, runtime, provider calls, prompt migration, automatic repair, catalog application or skill is included. Eight skills and twelve applications remain. Campfire's frozen dependencies and blocked native acceptance, historical trials, unfinished study and hosted release gate are outside this change.
