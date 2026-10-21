## MODIFIED Requirements

### Requirement: Conservative application-local installation

`foundry:skills` SHALL install the catalog to `.agents/skills` by default and accept `--target=claude` for `.claude/skills`; `--target=agents` SHALL select the default explicitly, and `--target=cursor` SHALL install under `.cursor/skills`. It SHALL preserve unrelated skills and project instructions, preserve complete customized installs on repeat with a matching versioned receipt, reject partial/conflicting installs, unsupported targets, and symbolic links, and support pretend mode without writes. Ordinary generation with a different source receipt SHALL refuse replacement. Explicit upgrade actions SHALL provide digest-bound assessment, safe updates, recorded customization review and conditional recovery without automatically merging user changes.

#### Scenario: Repeat an edited installation
- **WHEN** a user customizes an installed skill and repeats installation of the same catalog
- **THEN** the edited skill and unrelated files remain unchanged

#### Scenario: Unsafe or partial destination
- **WHEN** a target is a symbolic link or only part of the catalog exists
- **THEN** installation fails without overwriting existing files
