## MODIFIED Requirements

### Requirement: Generated component constants have one owner
Native component and agent generation SHALL reject a constant claimed by another component or agent/tool/schema receipt in the same context before writing files, including preview requests. It SHALL recognize existing receipts without rewriting them, preserve existing edited implementations and permit distinct constants with the same leaf name. Receipt checking SHALL NOT be presented as complete runtime constant resolution.

#### Scenario: Cross-kind collision
- **WHEN** a modular context already has an operation named quote and model quote is requested
- **THEN** generation rejects the duplicate constant and identifies its existing receipt without changing files

#### Scenario: Distinct domain categories
- **WHEN** command quote and query quote are generated in a domain context
- **THEN** their distinct categorized constants are permitted and repeat generation remains safe

#### Scenario: Agent and component conflict
- **WHEN** a component constant matches a generated agent, tool or schema constant in either generation order
- **THEN** generation and preview refuse before creating files, including shared AI configuration

## ADDED Requirements

### Requirement: Application-owned namespace inflections
Fresh context and new component or agent generation SHALL automatically supply application-owned loading configuration when the namespace requires special capitalization. Generated namespace constants SHALL load in a fresh application process without Foundry in production. Inflections SHALL have independent ownership receipts, preserve customized files, and reject unsafe paths, partial ownership and conflicting configured namespace mappings before writing. Generation SHALL NOT execute application initializers or change global naming rules to inspect configuration.

#### Scenario: Acronym and nested namespaces
- **WHEN** generation uses API, APIClient, GraphQL or a nested namespace containing these segments
- **THEN** fresh-process eager loading resolves the configured constants through generated application-owned configuration

#### Scenario: Conflicting capitalization
- **WHEN** another configured namespace requires the same directory basename to resolve to a different constant segment
- **THEN** generation refuses with both conflicting names and leaves the application unchanged

#### Scenario: Safe ownership and repeats
- **WHEN** owned inflection configuration has been customized
- **THEN** subsequent generation preserves it
- **AND** missing ownership or a partial scaffold causes a non-destructive refusal

#### Scenario: Previously completed scaffold
- **WHEN** a complete existing scaffold is generated again without an inflection receipt
- **THEN** the repeat preserves the existing files and does not implicitly repair them
- **AND** documented explicit repair explains how to supply the missing loading configuration
