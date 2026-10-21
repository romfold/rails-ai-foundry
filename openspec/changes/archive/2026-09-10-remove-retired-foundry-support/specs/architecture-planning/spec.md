## MODIFIED Requirements

### Requirement: Consistent source migration evidence
Context refactoring SHALL share AST diagnostics and boundary guidance with native source checking while retaining its selected-context scope, including tests. Development-tool dependency findings SHALL remain advisory during planning. Malformed Ruby SHALL make the assessment incomplete and fail the command without writes.

#### Scenario: Namespaced and nested references
- **WHEN** a context contains Other::RailsAIFoundry::Operation and RailsAIFoundry::AI::Agent
- **THEN** only the latter matches the Foundry namespace and its full constant name is reported
- **AND** the report states that constant resolution and dynamic calls are not proven

#### Scenario: Unparseable context test
- **WHEN** Ruby in the selected context's tests cannot be parsed
- **THEN** the report sets complete to false and the CLI returns failure while preserving files
