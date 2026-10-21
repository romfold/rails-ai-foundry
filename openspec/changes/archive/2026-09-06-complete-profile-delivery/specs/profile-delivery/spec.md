## Purpose

Deliver all profile workflows from the packaged gem with conservative transitions and complete, locally installed architecture guidance.

## ADDED Requirements

### Requirement: Explicit profile promotion
`foundry:profile PACKAGE --to=PROFILE` SHALL preview target conventions and stage requested missing component scaffolds outside active load roots. Pretend mode SHALL perform no writes. Repeats SHALL preserve staged edits and incompatible repeats SHALL fail. Existing business behavior and stored data SHALL never be rewritten or converted automatically.

#### Scenario: Stage without activation
- **WHEN** a developer stages a modular command for an MVP package
- **THEN** the current manifest and loading behavior remain active while editable target scaffolds and review guidance are available outside app roots

### Requirement: Checked activation
Promotion SHALL keep the old profile active until target structural, convention, and boundary checks pass and the developer explicitly requests activation. Activation SHALL preserve existing files, reject collisions and concurrent edits, and publish registration only after new artifacts are safely written. Event-sourcing activation SHALL require an explicit reviewed migration, cutover, and rollback procedure. Version 1 SHALL require a separately reviewed manifest migration.

#### Scenario: Failed target checks
- **WHEN** activation encounters a misplaced source, invalid staged namespace, or private cross-package reference
- **THEN** it reports actionable diagnostics without changing the active manifest or overwriting business code

#### Scenario: Activate reviewed event sourcing
- **WHEN** target checks pass and the developer explicitly activates with a reviewed migration and cutover procedure
- **THEN** the profile changes without executing a data conversion or deployment command

### Requirement: Packaged profile workflow
The built gem SHALL provide all four profiles, their generators, runtime resources, installed skill references, and application guidance. Acceptance SHALL run install, generate, implement, check, and relevant runtime workflows in minimal Rails hosts without examples, credentials, network calls, or source-checkout loading.

#### Scenario: Installed archive acceptance
- **WHEN** the archive is installed into isolated gem storage and minimal hosts
- **THEN** every profile runs its supported workflow, repeated generation preserves edits, and loaded Foundry files originate from the installed archive

### Requirement: Generated application guidance
Fresh installation SHALL create conservative application guidance routing developers to the manifest and installed skills using available commands, preserving existing application instructions and customized guidance.

#### Scenario: Repeated guidance installation
- **WHEN** a developer edits the generated guidance and repeats installation
- **THEN** the edited guide and existing application instructions remain unchanged
