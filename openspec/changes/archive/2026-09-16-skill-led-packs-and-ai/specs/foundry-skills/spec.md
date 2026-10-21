## ADDED Requirements

### Requirement: Skill-led package and feature development
The eight product skills SHALL guide ownership, invariants, state, consistency, integrations and measured workload decisions before implementation. They SHALL route to the selected specification workflow, allow plain plans with none, and treat small generators as optional. Package guidance SHALL name Rails, packs, packs-rails and Packwerk foundations, use direct upstream commands, distinguish mutating operations from checks, preserve custom roots and accepted debt, and require reviewed reconciliation of moved code and receipts.

#### Scenario: Create a context without a Foundry generator
- **WHEN** a user creates a plain pack using upstream tooling
- **THEN** guidance explains adding adjacent architectural intent, public APIs, declared dependencies and behavioral/loading verification
- **AND** no Foundry CLI wrapper or capability generator is required

#### Scenario: Adapt RAG through a skill
- **WHEN** a feature needs retrieval
- **THEN** the skill points to the worked RAG example and guides tenant, lifecycle, authorization and offline evidence choices without copying an application blindly
