# Knowledge lifecycle

## Purpose

Preserve tenant-scoped document behavior through incremental application changes.

## Requirements

### Requirement: Current authorized document lifecycle
The application SHALL preserve document identity, tenant ownership and optimistic revisions across creation, editing, publication, withdrawal and deletion. Invalid or unauthorized mutations SHALL not change persisted state.

#### Scenario: Characterized behavior survives extraction
- **WHEN** code is moved into a business package
- **THEN** the same lifecycle, authorization, rollback and HTTP acceptance passes against the same tables
