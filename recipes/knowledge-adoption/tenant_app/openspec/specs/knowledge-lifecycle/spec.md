# Collection-owned knowledge

## Purpose

Preserve authorized document behavior while extracting a package before changing ownership storage.

## Requirements

### Requirement: Trusted collection ownership
The application SHALL derive visibility and write authorization from trusted collection ownership. It SHALL preserve document IDs, revisions, content and timestamps through extraction. Unmapped collections SHALL remain inaccessible; request parameters SHALL NOT assign ownership.

#### Scenario: Characterized behavior survives extraction
- **WHEN** Knowledge moves into a pack
- **THEN** the same create, edit, delete, isolation and optimistic-conflict acceptance passes against the existing tables
