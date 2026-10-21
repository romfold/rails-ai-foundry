## MODIFIED Requirements

### Requirement: Versioned manifest contract

The application manifest SHALL be a data-only YAML mapping containing `version: 1` or `version: 2` and a `packages` mapping. Each package SHALL have a unique lowercase snake_case identifier, a `type` of `domain` or `platform`, and an explicit list of dependency identifiers. The reserved identifier `platform`, unknown manifest fields, duplicate mapping keys, invalid field types, duplicate dependencies, YAML aliases, custom object tags, and executable template interpolation MUST be rejected. Version 2 entries SHALL additionally require a profile of mvp, modular, domain, or event_sourced. Version 1 SHALL reject profile fields and retain legacy semantics. An empty package mapping SHALL be valid.

#### Scenario: Accept an empty installation

- **WHEN** the manifest declares version 1 and `packages: {}`
- **THEN** the configuration is accepted without requiring any business packages

#### Scenario: Accept domain and platform declarations

- **WHEN** the manifest declares `billing` as a domain package depending on the platform package `messaging`, with explicit dependency lists
- **THEN** those package declarations are accepted

#### Scenario: Reject unsupported or ambiguous configuration

- **WHEN** the manifest uses an unsupported version, repeats a key, omits a required field, introduces an unknown field, or uses an invalid value type
- **THEN** configuration validation fails with the source path and the affected field or location

#### Scenario: Do not evaluate configuration as code

- **WHEN** the manifest contains an object tag, alias, or executable template expression
- **THEN** validation rejects the input without evaluating it or constructing arbitrary objects

#### Scenario: Explicit profiles

- **WHEN** a version 2 entry has a supported explicit profile
- **THEN** the manifest is accepted
- **AND** missing or unknown profiles are rejected
