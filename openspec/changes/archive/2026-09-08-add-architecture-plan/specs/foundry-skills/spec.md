## MODIFIED Requirements

### Requirement: Self-contained product skills

The gem SHALL include eight skills for adding packages, implementing features, architecture review, delivery checks, profile promotion, event workflows, guided existing-app adoption, and optional architecture planning. Each SHALL have valid name/description frontmatter, a version matching the gem, and locally installed bundled references. Convention tables SHALL be generated from the same profile registry used by commands and checks. Instructions SHALL use implemented commands and distinguish structural/static checks from runtime proof. Skills SHALL preserve user scope and SHALL NOT require OpenSpec, examples, model credentials, or a specific coding agent.

#### Scenario: Consume the packaged catalog
- **WHEN** the built gem is installed without its source checkout
- **THEN** every skill and any referenced resource is available locally


#### Scenario: Optional planning workflow
- **WHEN** ownership or profile decisions are unclear
- **THEN** the planning skill guides a concrete reviewed proposal before apply while direct explicit generation remains available without a plan

#### Scenario: Review existing seven-skill catalog
- **WHEN** an existing seven-skill installation is upgraded
- **THEN** installation requires manual catalog reconciliation and preserves customized guidance
