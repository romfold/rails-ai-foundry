## Purpose

Deliver reusable Foundry implementation guidance with the same versioned gem that supplies its commands.

## ADDED Requirements

### Requirement: Self-contained product skills

The gem SHALL include four skills for adding packages, implementing features, architecture review, and delivery checks. Each SHALL have valid name/description frontmatter, a version matching the gem, and self-contained instructions or bundled references. Instructions SHALL use implemented commands and distinguish structural/static checks from runtime proof. Skills SHALL preserve user scope and SHALL NOT require OpenSpec, examples, model credentials, or a specific coding agent.

#### Scenario: Consume the packaged catalog
- **WHEN** the built gem is installed without its source checkout
- **THEN** every skill and any referenced resource is available locally

### Requirement: Conservative application-local installation

`foundry:skills` SHALL install the catalog to `.agents/skills` by default and accept `--target=claude` for `.claude/skills`; `--target=agents` SHALL select the default explicitly. It SHALL preserve unrelated skills and project instructions, preserve complete customized installs on repeat with a matching versioned receipt, reject partial/conflicting installs, unsupported targets, and symbolic links, and support pretend mode without writes. Upgrades with a different source receipt SHALL require manual review rather than overwriting user changes.

#### Scenario: Repeat an edited installation
- **WHEN** a user customizes an installed skill and repeats installation of the same catalog
- **THEN** the edited skill and unrelated files remain unchanged

#### Scenario: Unsafe or partial destination
- **WHEN** a target is a symbolic link or only part of the catalog exists
- **THEN** installation fails without overwriting existing files
