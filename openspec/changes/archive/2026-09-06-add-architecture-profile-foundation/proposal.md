## Why

The core accepts arbitrary package folders and has no machine-readable architecture profiles. Developers and agents need one canonical layout without changing the meaning of existing packages.

## What Changes

- **BREAKING** Raise Ruby minimum to 3.3; retain railties >= 7.1.
- Add manifest version 2, four named profiles, a shared layout registry, profile-aware package generation/loading, and static convention validation.
- Keep version 1 behavior and existing package paths unchanged; install version 2 in fresh hosts.

## Capabilities

### New Capabilities

- `architecture-profiles`: Canonical profile registry and folder validation.

### Modified Capabilities

- `package-configuration`: Accept version 2 with explicit package profiles.
- `framework-installation`: Fresh manifest version and Ruby compatibility floor.

## Impact

Manifest parsing, package generation, loading, checks, tests, documentation, gem metadata, and contributor compatibility guidance. Runtime operations and event integrations follow in separate changes. Support desk remains deferred.
