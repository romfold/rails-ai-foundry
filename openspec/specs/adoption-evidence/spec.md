# adoption-evidence Specification

## Purpose

Support incremental adoption with complete debt identities and application-specific parity evidence.

## Requirements

### Requirement: Disposable debt audit
Debt audit SHALL regenerate upstream debt only in disposable application copies, report new, retained and resolved violation identities, preserve source baseline bytes, and fail on new debt or failed upstream analysis.

#### Scenario: Resolved baseline
- **WHEN** all references behind an accepted violation have disappeared
- **THEN** audit reports the resolved identities even if ordinary upstream checking misses the stale file

### Requirement: Application parity
Parity verification SHALL compare Packwerk and pks identities on the same application snapshot, record tool and input fingerprints, and reject mismatched or stale evidence. Packwerk SHALL remain authoritative; pks SHALL never become the default merely because it is installed.

#### Scenario: Parity mismatch
- **WHEN** pks omits or adds a violation relative to Packwerk
- **THEN** verification fails and does not enable it

### Requirement: Adoption inventory
Read-only adoption SHALL identify upstream packages, existing workflow and baseline identities with incremental extraction guidance without modifying application files. Recommendations SHALL distinguish configured contexts from packages without architectural intent and identify whether workflow initialization is needed. Existing initialized workflows and explicit opt-out SHALL not be treated as missing setup.

#### Scenario: Existing roots
- **WHEN** adoption inspects an existing application
- **THEN** its roots, workflow and accepted debt remain unchanged
- **AND** recommendations reference the discovered package locations

#### Scenario: Existing configured context
- **WHEN** an application already has a configured context and initialized workflow
- **THEN** recommendations identify focused assessment/checkpoint work for that context without recommending redundant workflow initialization

### Requirement: Private and consistent audit inputs
Adoption debt inventory and disposable debt audit SHALL apply the same documented input eligibility policy. Audit inventory, copies and fingerprints SHALL exclude Claude metadata and application-root private skill-upgrade sessions before reading their contents, while retaining normal Foundry receipts and architecture inputs. Excluded baselines SHALL NOT contribute accepted, retained, new or resolved identities. Eligible malformed, unreadable or missing inputs SHALL fail safely without exposing contents.

#### Scenario: Private metadata and excluded baselines
- **WHEN** an application contains `.claude` guidance, `.foundry/skill-upgrades` backups and a vendor baseline
- **THEN** none of those excluded inputs is read into audit copies or fingerprints
- **AND** their baseline identities do not appear in adoption or audit debt inventories
- **AND** ordinary Foundry receipts remain eligible inputs

#### Scenario: Regenerated baseline added by analysis
- **WHEN** an analyzer creates an eligible baseline absent from the original inventory
- **THEN** its full violation identities contribute to the regenerated debt comparison
- **AND** source baselines remain unchanged

### Requirement: Verified shared capture
Each audit or parity operation SHALL derive accepted debt and independent analyzer working copies from one verified captured application snapshot. Copied file bytes SHALL match the captured inventory. Detected source changes, incomplete reads or inconsistent copies SHALL prevent successful evidence. One backend's mutations SHALL NOT become another backend's inputs. Temporary roots SHALL be owner-private and removed on normal completion or exceptions. This guarantee SHALL NOT be described as a filesystem-atomic snapshot or an execution sandbox.

#### Scenario: Transient source mutation during copy
- **WHEN** a source file changes during copying and returns to its initial bytes before the source inventory is checked
- **THEN** a destination differing from the captured hash causes capture failure
- **AND** no analyzer runs against that inconsistent snapshot

#### Scenario: Independent parity analysis
- **WHEN** Packwerk regenerates debt and modifies its working copy
- **THEN** pks starts from an independent copy of the same pristine captured inputs
- **AND** accepted debt was read from that pristine capture

#### Scenario: Backend failure
- **WHEN** upstream analysis fails after temporary copies are created
- **THEN** normal exception handling removes the temporary copies
- **AND** no source baseline is rewritten and no successful evidence is reported

### Requirement: Input policy bound fingerprints
Opaque audit/parity fingerprints SHALL bind the input-policy revision as well as eligible captured content without changing report schema 1. Verification SHALL reject prior-policy evidence and require regeneration. Historical evidence SHALL remain unchanged.

#### Scenario: Previously generated parity evidence
- **WHEN** a report used the prior input policy even though application bytes are unchanged
- **THEN** verification rejects it as stale and instructs regeneration

#### Scenario: Private edit versus eligible edit
- **WHEN** only excluded private metadata changes
- **THEN** the current eligible-input fingerprint remains unchanged
- **AND** an eligible source or receipt change changes the fingerprint
