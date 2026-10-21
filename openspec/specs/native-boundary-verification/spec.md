# native-boundary-verification Specification

## Purpose
Provide verified native boundary verification for Rails consumers while keeping Foundry a development-time conventions kit.

## Requirements

### Requirement: Explicit upstream boundary verification
Native checking SHALL remain boot-free unless the user explicitly selects `--boundaries`. Boundary verification SHALL invoke the consuming bundle's Packwerk validation and full check in a separate process with the Rails and Rack test environments and frozen bundle resolution. Foundry SHALL expose upstream output and failure status rather than reimplement topology, privacy, cycles or violation identity matching.

#### Scenario: Structural default
- **WHEN** a user runs foundry check without --boundaries
- **THEN** no Packwerk process or Rails boot is requested

#### Scenario: Explicit boundary verification
- **WHEN** a user runs foundry check --boundaries with a locked installed bundle and Packwerk configuration
- **THEN** upstream validate runs before check, and failed validation stops further verification
- **AND** either upstream failure produces a nonzero Foundry exit

### Requirement: Preserve upstream accepted debt
Boundary checking SHALL NOT generate or rewrite accepted debt. Upstream Packwerk SHALL determine whether references match its existing accepted violation identities. Foundry SHALL compare the application tree's package_todo.yml contents before and after verification and fail if they change, without restoring concurrent changes.

#### Scenario: New reference to an accepted constant
- **WHEN** an accepted constant violation appears in a different source file
- **THEN** upstream checking rejects that new violation and the existing baseline remains byte-identical

#### Scenario: Resolved reference
- **WHEN** upstream Packwerk reports a stale violation after a reference is removed
- **THEN** upstream stale-debt diagnostics are preserved and no baseline is pruned automatically

#### Scenario: Upstream stale-detection limits
- **WHEN** the selected Packwerk version does not report a fully resolved package baseline
- **THEN** Foundry preserves upstream behavior and reports that fully resolved baselines require separate review
- **AND** it does not claim complete cleanup verification or pks parity

#### Scenario: Concurrent baseline change
- **WHEN** a baseline is added, removed or modified during checking
- **THEN** Foundry reports failed verification even if upstream exits successfully
- **AND** the changed files remain available for user inspection

### Requirement: Locale-independent upstream report text
Boundary reports SHALL preserve valid UTF-8 upstream output independently of the caller's locale and replace invalid byte sequences with the Unicode replacement character. Encoding normalization SHALL NOT change command arguments, exit statuses or accepted debt.

#### Scenario: Non-ASCII output in the C locale
- **WHEN** upstream validation or checking emits Unicode under LC_ALL=C
- **THEN** the JSON report remains parseable and preserves the Unicode text and upstream status

#### Scenario: Invalid output bytes
- **WHEN** a successful or unsuccessful upstream command emits invalid UTF-8 bytes
- **THEN** report text contains replacement characters and the command's outcome remains unchanged
