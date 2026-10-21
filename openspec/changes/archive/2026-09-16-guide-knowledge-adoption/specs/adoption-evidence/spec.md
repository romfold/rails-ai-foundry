## MODIFIED Requirements

### Requirement: Adoption inventory
Read-only adoption SHALL identify upstream packages, existing workflow and baseline identities with incremental extraction guidance without modifying application files. Recommendations SHALL distinguish configured contexts from packages without architectural intent and identify whether workflow initialization is needed. Existing initialized workflows and explicit opt-out SHALL not be treated as missing setup.

#### Scenario: Existing roots
- **WHEN** adoption inspects an existing application
- **THEN** its roots, workflow and accepted debt remain unchanged
- **AND** recommendations reference the discovered package locations

#### Scenario: Existing configured context
- **WHEN** an application already has a configured context and initialized workflow
- **THEN** recommendations identify focused assessment/checkpoint work for that context without recommending redundant workflow initialization
