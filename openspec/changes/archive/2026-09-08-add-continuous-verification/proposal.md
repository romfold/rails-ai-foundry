## Why

The compatibility and installed-gem suites are currently verified locally. Automated pull-request and main-branch checks should preserve these contracts and make failures visible without deployment access.

## What Changes

- Add read-only GitHub Actions for the three current Ruby/Rails lanes, with separate core, AI and event dependency bundles.
- Run installed-gem/profile acceptance, PostgreSQL 17, SQLite, lint, skill/spec validation and the independently bundled support desk.
- Prepare dependencies before provider-blocked acceptance, record versions, and add a Git-backed Unreleased changelog.

## Capabilities

### New Capabilities
None. This is delivery tooling and documentation; runtime behavior is unchanged.

### Modified Capabilities
None.

## Impact

GitHub Actions, development scripts and CI bundle configuration, contributor documentation, CHANGELOG. No publishing or deployment credentials. Local verification is reported separately from unexecuted remote jobs.
