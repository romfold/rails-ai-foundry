## Why

Source and prompt checks now respect upstream package ownership, but `foundry plan refactor` still recursively inspects nested packages as part of their parent. Local reproduction also shows that selecting a configured root package fails before assessment, leaving the planning path inconsistent with the package model used elsewhere.

## What Changes

- Resolve the selected configured context and its source ownership from the consuming application's locked upstream package inventory, including sidecar-free descendants.
- Inspect only Ruby owned by the selected package, retaining tests and other existing non-root inspection locations. Support configured root packages with explicit exclusions for application-root dependency and generated-data directories.
- Prevent descendant syntax and model declarations from changing the selected parent's findings; preserve installed-profile rules, proposed-profile semantics and existing report/exit contracts.
- Fail safely on invalid discovery, unsafe paths and incomplete inspection, without booting Rails, executing source or modifying consumer files.
- Verify the built gem with standard, custom and nested roots, and update existing planning/profile-promotion guidance through reviewed skill upgrades.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `architecture-planning`: Define selected-package ownership, root-context assessment, safe inspection and unchanged read-only evidence semantics.

## Impact

Affected areas are the private refactor/context/package traversal helpers, focused core and packaged acceptance, existing planning references, adoption/source/stable-contract documentation and the roadmap. No new command, option, report field, configuration key, skill, runtime or application is introduced.

Keep Rails, Minitest and every existing locked dependency unchanged. Preserve eight skills, twelve applications, workflow history, customizations, receipts and accepted debt. Campfire's blocked native-test acceptance, unfinished studies and the hosted release gate remain separate; hosted CI, publication, provider calls and agent trials are excluded.
