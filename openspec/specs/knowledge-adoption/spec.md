# knowledge-adoption Specification

## Purpose

Demonstrate independently useful adoption checkpoints while preserving an existing knowledge application's behavior and data.

## Requirements

### Requirement: Independently verified adoption checkpoints
The walkthrough SHALL start with an ordinary Rails knowledge application and verify characterization, read-only assessment, package extraction retaining existing persistence, public caller repair, a separate persistence transition, and later integration features. Extraction SHALL remain useful without the advanced stack.

#### Scenario: Extract without changing persistence
- **WHEN** the extraction checkpoint is replayed
- **THEN** characterized endpoints, authorization, data and failures remain equivalent with existing tables and persistence
- **AND** package boundaries detect an intentional private caller violation before repair

#### Scenario: Change persistence later
- **WHEN** the separate persistence checkpoint is applied to existing data
- **THEN** identity, revisions, tenant ownership and lifecycle behavior are preserved
- **AND** rollback instructions identify the checkpoint and data compatibility limits

### Requirement: Disposable installed-gem replay
Adoption acceptance SHALL replay against an installed gem in disposable applications, preserve custom package roots, selected workflow history and accepted debt, and independently verify each checkpoint.

#### Scenario: Existing workflow and custom roots
- **WHEN** replay uses non-default package roots and an existing specification workflow
- **THEN** assessment and subsequent extraction preserve those roots and workflow artifacts
- **AND** normal checking does not regenerate accepted debt
