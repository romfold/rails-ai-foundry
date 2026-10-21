## ADDED Requirements

### Requirement: Misplaced package intent is rejected
Discovery SHALL reject config/foundry.yml inside a discovered non-root package and identify the adjacent foundry.yml location. It SHALL NOT merge, move or prefer conflicting files. Ordinary packages without intent and application-root configuration remain valid.

#### Scenario: Misplaced or duplicate sidecar
- **WHEN** a discovered package contains config/foundry.yml, with or without adjacent foundry.yml
- **THEN** configuration assessment fails with both paths in actionable guidance without changing files

#### Scenario: Incremental adoption
- **WHEN** packages have no Foundry intent
- **THEN** discovery allows them and may report zero configured contexts
