## Purpose

Identify executable examples by descriptive profile-first names and their actual focal configuration.

## ADDED Requirements

### Requirement: Configuration-derived catalog
The catalog SHALL record only application location and focal context. Verification SHALL read the installed profile and reject mismatched prefixes, missing configurations and missing README links. Planned applications SHALL NOT be listed as executable examples.

#### Scenario: Mismatched prefix
- **WHEN** a catalog location prefix disagrees with its focal context profile
- **THEN** catalog verification fails with the location and profile
