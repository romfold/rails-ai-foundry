## Purpose

Provide explicitly experimental external vector recipes with safe tenant and version boundaries.

## ADDED Requirements

### Requirement: Scoped external vectors
Experimental vector recipes SHALL require trusted tenant and embedding-version scope for writes, searches and deletion, surface provider failures, and recheck authoritative records before returning citations. Rebuild guidance SHALL preserve the previous serving generation until validation succeeds.

#### Scenario: Stale provider result
- **WHEN** an index returns a deleted or outdated document
- **THEN** the authoritative check excludes it from citations

### Requirement: Evidence tiers
Experimental recipes SHALL distinguish offline protocol acceptance, local service acceptance and live provider evidence. Normal tests SHALL make no external provider calls.

#### Scenario: Unavailable provider
- **WHEN** a provider fails or returns malformed data
- **THEN** the recipe reports failure without claiming a successful search or cutover
