## Why

Native root discovery can omit pack-owned tests, while explicit package paths can replace root coverage. Installed verification needs an opt-in complete non-system baseline with proof that its planned files loaded.

## What Changes

- Add `--include-pack-tests` to the existing helper for Minitest and RSpec, using locked upstream package discovery.
- Combine root, package and explicit additional paths, print the inventory and defer browser tests to explicit selections.
- Verify loaded files independently of executed test ownership, preserving existing invocations and outcome checks.
- Ship an application-owned verification command guide and verify installed upgrades across targets and roots.

## Capabilities

### New Capabilities
- `package-aware-verification`: Opt-in combined baseline discovery, loaded-file evidence and installed application workflow.

### Modified Capabilities
None. Existing non-opt-in helper behavior remains unchanged.

## Impact

Installed skill scripts, relevant guidance, archive inventory, acceptance tests and stable helper documentation. No runtime, public configuration schema, CLI command, provider, hosted CI, publication or agent trial.
