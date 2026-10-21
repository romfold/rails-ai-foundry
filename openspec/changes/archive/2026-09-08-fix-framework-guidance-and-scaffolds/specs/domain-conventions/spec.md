## ADDED Requirements

### Requirement: Transactional command scaffold example
New command scaffolds SHALL demonstrate the existing `steps` and `step` contract so application writes performed in that block use the command transaction boundary. Generation SHALL preserve existing command files and their customized implementations.

#### Scenario: Generate a new command
- **WHEN** a command is generated in a compatible registered package
- **THEN** its neutral implementation demonstrates steps and step without adding business behavior

#### Scenario: Repeat an edited scaffold
- **WHEN** the same command generation is repeated after application edits
- **THEN** existing source remains unchanged
