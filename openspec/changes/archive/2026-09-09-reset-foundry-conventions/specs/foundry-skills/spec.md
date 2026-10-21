## ADDED Requirements

### Requirement: Optional application specification workflow
Product skills SHALL direct agents to the selected application workflow without requiring OpenSpec. Workflow references SHALL distinguish behavioral requirements, architectural intent, topology and implementation evidence.

#### Scenario: Spec Kit application
- **WHEN** an agent works in an application selecting spec_kit
- **THEN** the installed guidance follows that workflow and reads the owning context's actual configuration

#### Scenario: No specification workflow
- **WHEN** an application selects none
- **THEN** skills still prescribe targeted tests and architecture checks without requiring specification artifacts

## MODIFIED Requirements

### Requirement: Self-contained product skills

The gem SHALL include eight skills for adding packages, implementing features, architecture review, delivery checks, explicit profile refactoring, event workflows, guided existing-app adoption, and workflow-aware architecture planning. Each SHALL have valid name/description frontmatter, a version matching the gem, and locally installed bundled references. Guidance SHALL reference installed context configuration rather than duplicate a package inventory or prescribe removed runtimes. Instructions SHALL use implemented commands and distinguish structural/static checks from runtime proof. Skills SHALL preserve user scope and SHALL NOT require OpenSpec, examples, model credentials, or a specific coding agent.

#### Scenario: Consume the packaged catalog
- **WHEN** the built gem is installed without its source checkout
- **THEN** every skill and any referenced resource is available locally

#### Scenario: Optional planning workflow
- **WHEN** ownership or profile decisions are unclear
- **THEN** the planning skill guides a concrete reviewed proposal before apply while direct explicit generation remains available without a plan

#### Scenario: Review existing seven-skill catalog
- **WHEN** an existing seven-skill installation is upgraded
- **THEN** installation requires manual catalog reconciliation and preserves customized guidance


### Requirement: Conservative application-local installation

`foundry:skills` SHALL install the catalog to `.agents/skills` by default and accept `--target=claude` for `.claude/skills`; `--target=agents` SHALL select the default explicitly, and `--target=cursor` SHALL install under `.cursor/skills`. It SHALL preserve unrelated skills and project instructions, preserve complete customized installs on repeat with a matching versioned receipt, reject partial/conflicting installs, unsupported targets, and symbolic links, and support pretend mode without writes. Upgrades with a different source receipt SHALL require manual review rather than overwriting user changes.

#### Scenario: Repeat an edited installation
- **WHEN** a user customizes an installed skill and repeats installation of the same catalog
- **THEN** the edited skill and unrelated files remain unchanged

#### Scenario: Unsafe or partial destination
- **WHEN** a target is a symbolic link or only part of the catalog exists
- **THEN** installation fails without overwriting existing files
