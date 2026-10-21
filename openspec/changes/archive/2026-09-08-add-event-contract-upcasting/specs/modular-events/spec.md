## MODIFIED Requirements

### Requirement: Versioned events remain independent of persistence

Event contracts SHALL have stable identifiers, explicit types and versions, immutable JSON-compatible data, and no Rails dependency. Persistence adapters SHALL map those contracts to stored records. One current contract per TYPE SHALL be registered; explicitly declared complete read-time upcaster chains MAY support older payload versions without altering stored records. Unknown event types and unsupported versions SHALL fail with actionable diagnostics instead of constructing arbitrary classes.

#### Scenario: Read unsupported event version

- **WHEN** a stored event version is not supported by its explicitly registered contract or a complete owned upcaster chain
- **THEN** reading fails and identifies the type and version without modifying the stream

