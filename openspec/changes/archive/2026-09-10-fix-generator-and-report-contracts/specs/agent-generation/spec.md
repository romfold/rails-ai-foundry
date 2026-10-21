## ADDED Requirements

### Requirement: Agent scaffold ownership includes all runtime constants
Agent generation SHALL preflight the agent, tool and schema constants against component and agent receipts before writing any artifact. New agents SHALL participate in application-owned namespace inflection installation. Completed customized agents SHALL remain safe to repeat without receipt conversion.

#### Scenario: Component claims a tool or schema
- **WHEN** the requested agent's tool or schema constant is already owned by a component
- **THEN** generation and preview fail before creating prompts, shared aliases, inflections or receipts

#### Scenario: Existing agent receipt
- **WHEN** a component would claim a runtime constant described by an existing agent receipt
- **THEN** the component is refused and the receipt remains byte-identical
